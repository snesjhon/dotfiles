# mux [session] -- attach this terminal to an nvim session (see
# nvim/lua/mux): every tab is a shell. Each session is a headless nvim
# server, so it keeps running when the terminal closes. With no argument, pick a
# session from nvim/lua/mux/defs.lua with fzf. Inside a session, mux switches that window to another session.
# mux restart -- reload the nvim config in every running session; shells keep running.
# mux kill -- stop every process in the sessions' shells, then quit the sessions.
# mux new <branch> [base] -- create a worktree and switch to its session (see _mux_new).
# mux rm [name] -- stop a worktree session and remove the worktree (see _mux_rm).

# One line per session: name, folder, worktree folder (repo sessions), parent
# session (worktree sessions), separated by tabs.
_mux_sessions() {
  # io.stdout, not print: `nvim -l` sends print() to stderr.
  command nvim --clean -l <(print -r '
    local function x(p) return p and vim.fn.expand(p) or "" end
    for k, d in pairs(dofile(_G.arg[1])) do
      io.stdout:write(table.concat({ k, x(d.path), x(d.worktrees), d.parent or "" }, "\t"), "\n")
    end') "$HOME/.config/nvim/lua/mux/defs.lua"
}

# Splits a _mux_sessions line into $reply. read would merge the tabs around an empty field.
_mux_fields() { reply=("${(@ps:\t:)1}") }

_mux_names() { print -l ${${(f)"$(_mux_sessions)"}%%$'\t'*} }

_mux_dir=${TMPDIR:-/tmp}
_mux_dir=${_mux_dir%/}/mux-sessions

# --headless and no stdin: from inside a terminal buffer a plain nvim client
# starts a TUI first (escape codes, waits on the terminal), which is slow.
_mux_alive() { command nvim --headless --server $1 --remote-expr 1 </dev/null &>/dev/null }

# Start the session's server if it isn't running, and wait until it answers.
_mux_ensure() {
  local sock=$_mux_dir/$1.sock i
  _mux_alive $sock && return
  rm -f $sock
  mkdir -p $_mux_dir
  # &! detaches the server from this shell so closing the terminal doesn't stop it.
  command nvim --headless --listen $sock --cmd 'let g:mux = 1' +"Session $1" &>/dev/null &!
  for i in {1..100}; do
    _mux_alive $sock && return
    sleep 0.05
  done
  print -u2 "mux: session $1 did not start"
  return 1
}

# Re-run the nvim config in every running session (see reload in nvim/lua/mux).
_mux_restart() {
  local sock err n=0
  for sock in $_mux_dir/*.sock(N=); do
    _mux_alive $sock || continue
    err=$(command nvim --headless --server $sock --remote-expr "v:lua.require'mux'.reload()" </dev/null 2>&1)
    if [[ -n $err ]]; then
      print -u2 "mux: ${sock:t:r}: $err"
    else
      (( n++ ))
    fi
  done
  if (( ! n )); then
    print -u2 "mux: no sessions reloaded"
    return 1
  fi
  print "mux: reloaded config in $n session(s)"
}

# Quit the given session sockets' servers (default: all). Each shell gets a hangup, but anything that
# outlives it (background jobs, tools that ignore the hangup) keeps running.
_mux_quit() {
  local sock own n=0 socks=($@)
  (( $# )) || socks=($_mux_dir/*.sock(N=))
  for sock in $socks; do
    if _mux_alive $sock; then
      # Run inside a session, quitting its own server ends this shell, so that one goes last.
      [[ $sock == $NVIM ]] && { own=$sock; (( n++ )); continue }
      command nvim --headless --server $sock --remote-send '<Cmd>qa!<CR>' </dev/null 2>/dev/null && (( n++ ))
    else
      rm -f $sock # nothing is listening, so this is a leftover file
    fi
  done
  if (( ! n )); then
    print -u2 "mux: no running sessions"
    return 1
  fi
  print "mux: stopped $n session(s)"
  [[ -n $own ]] && command nvim --headless --server $own --remote-send '<Cmd>qa!<CR>' </dev/null 2>/dev/null
  return 0
}

# Stop every process on the given session sockets' ptys (default: all) and
# their children, which catches ones that moved off the pty. Sets reply to the
# number of sessions and processes; fails when no session is running.
_mux_kill_procs() {
  local sock pty p pp i n=0 pids=() queue=() alive=() socks=($@)
  local -A kids
  (( $# )) || socks=($_mux_dir/*.sock(N=))
  ps -A -o pid=,ppid= | while read p pp; do kids[$pp]+=" $p"; done
  for sock in $socks; do
    _mux_alive $sock || continue
    (( n++ ))
    for pty in ${(f)"$(command nvim --headless --server $sock --remote-expr "v:lua.require'mux'.ptys()" </dev/null 2>/dev/null)"}; do
      queue+=(${=$(ps -o pid= -t ${pty:t})})
    done
  done
  (( n )) || return 1
  while (( $#queue )); do
    p=$queue[1]
    shift queue
    (( ${pids[(Ie)$p]} )) && continue
    pids+=($p)
    queue+=(${=kids[$p]})
  done
  pids=(${pids:#$$}) # this shell, when run inside a session
  if (( $#pids )); then
    kill -TERM $pids 2>/dev/null
    # Give them a second to exit cleanly before forcing it.
    for i in {1..20}; do
      alive=()
      for p in $pids; do kill -0 $p 2>/dev/null && alive+=($p); done
      (( $#alive )) || break
      sleep 0.05
    done
    (( $#alive )) && kill -KILL $alive 2>/dev/null
  fi
  reply=($n $#pids)
}

# Stop every process in the sessions, then quit the servers.
_mux_kill() {
  _mux_kill_procs || { print -u2 "mux: no running sessions"; return 1 }
  print "mux: killed $reply[1] session(s) and $reply[2] process(es)"
  # A session quits by itself once its last shell exits, so this only catches the rest.
  _mux_quit &>/dev/null
  return 0
}

# Stops worktree session <name> (default: this window's) and everything running
# in it, then removes the worktree. The branch is kept.
_mux_rm() {
  local name=${1:-${NVIM:t:r}} dir repo line
  for line in ${(f)"$(_mux_sessions)"}; do
    _mux_fields $line
    [[ $reply[1] == $name && -n $reply[4] ]] && dir=$reply[2]
  done
  [[ -z $dir ]] && { print -u2 "mux: ${name:-this window} is not a worktree session"; return 1 }
  # git refuses to remove a worktree with changes, so check before stopping anything.
  if [[ -n $(git -C $dir status --porcelain) ]]; then
    print -u2 "mux: $name has uncommitted changes"
    return 1
  fi
  repo=$(git -C $dir rev-parse --path-format=absolute --git-common-dir) || return 1
  repo=${repo:h}
  _mux_kill_procs $_mux_dir/$name.sock
  [[ $PWD == $dir(|/*) ]] && cd $repo
  git -C $repo worktree remove $dir || return 1
  print "mux: removed $name; its branch is kept"
  # Run inside that session, this ends this shell and closes the window.
  _mux_quit $_mux_dir/$name.sock &>/dev/null
  return 0
}

# fzf list of the sessions in mux/defs.lua; ▶ marks the one this window is on
# and ● the other running ones. The preview shows the folder's git state and PR.
_mux_pick() {
  local name dir mark current=${NVIM:t:r}
  _mux_sessions | sort | while IFS=$'\t' read -r name dir _; do
    if [[ $name == $current ]]; then
      mark=▶
    elif [[ -S $_mux_dir/$name.sock ]] && _mux_alive $_mux_dir/$name.sock; then
      mark=●
    else
      mark=' '
    fi
    print -r -- "$mark $name"$'\t'"$dir"
  done | fzf --height 60% --border-label ' Sessions ' --border-label-pos 2 \
    --delimiter $'\t' --with-nth 1 --preview "${ZSH_CONFIG_DIR:h}/scripts/mux-preview.sh {2}" \
    | cut -f1 | awk '{print $NF}'
}

# Creates a worktree for <branch> in the worktree folder of the repo this shell
# is in, or of the only repo with one when the shell is in none. An existing
# branch (local or on origin) is checked out; a new one starts from origin's
# [base], by default origin's default branch. Then switches to its session.
_mux_new() {
  local branch=$1 base=$2 repo dir name line
  [[ -z $branch ]] && { print -u2 "usage: mux new <branch> [base]"; return 1 }
  local -A dirs # repo folder -> its worktree folder
  for line in ${(f)"$(_mux_sessions)"}; do
    _mux_fields $line
    [[ -n $reply[3] ]] && dirs[$reply[2]]=$reply[3]
  done
  repo=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  repo=${repo:h}
  if [[ -z ${dirs[$repo]} ]]; then
    if (( $#dirs != 1 )); then
      print -u2 "mux: run inside a repo with worktrees set in mux/defs.lua: ${(kj:, :)dirs}"
      return 1
    fi
    repo=${(k)dirs}
  fi
  dir=${dirs[$repo]}
  name=${branch:t}
  [[ -e $dir/$name ]] && { print -u2 "mux: $dir/$name already exists"; return 1 }
  if git -C $repo show-ref -q --verify refs/heads/$branch ||
    git -C $repo show-ref -q --verify refs/remotes/origin/$branch; then
    git -C $repo worktree add $dir/$name $branch || return 1
  else
    if [[ -z $base ]]; then
      base=$(git -C $repo symbolic-ref --short refs/remotes/origin/HEAD) || return 1
      base=${base#origin/}
    fi
    git -C $repo fetch -q origin $base || return 1
    # --no-track: the branch is pushed under its own name, not to base.
    git -C $repo worktree add --no-track -b $branch $dir/$name origin/$base || return 1
  fi
  mux $name
}

mux() {
  [[ $1 == new ]] && { _mux_new $2 $3; return }
  [[ $1 == rm ]] && { _mux_rm $2; return }
  [[ $1 == kill ]] && { _mux_kill; return }
  [[ $1 == restart ]] && { _mux_restart; return }
  local name=$1
  [[ -z $name ]] && name=$(_mux_pick)
  [[ -z $name ]] && return
  if [[ -n $NVIM ]]; then
    # Moving the window to another session has to run from the UI's own input,
    # which a shell can't send. mux.sh presses a key that nvim maps to it.
    "${ZSH_CONFIG_DIR:h}/scripts/mux.sh" $name
    return
  fi
  _mux_ensure $name || return 1
  command nvim --remote-ui --server $_mux_dir/$name.sock
}

_mux() { compadd -- kill new restart rm $(_mux_names) }
compdef _mux mux
