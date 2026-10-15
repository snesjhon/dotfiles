# mux [session] -- attach this terminal to an nvim session (see
# nvim/lua/mux): every tab is a shell. Each session is a headless nvim
# server, so it keeps running when the terminal closes. With no argument, pick a
# session from nvim/lua/mux/defs.lua with fzf. Inside a session, mux switches that window to another session.
# mux restart -- reload the nvim config in every running session; shells keep running.
# mux kill -- stop every process in the sessions' shells, then quit the sessions.
# mux new <branch> [base] -- create a worktree and switch to its session (see _mux_new).
# mux ticket <id or URL> [-n name | -b branch] [instructions...] -- create a worktree and run /ticket in its session (see _mux_ticket).
# mux plan [name] -- open a /ticket plan in nvim (see _mux_plan).
# mux revise [name] -- run /ticket revise in a session once its draft PR is reviewed (see _mux_ticket_run).
# mux test [name] -- run /ticket test in a session to build a test project and tags (see _mux_ticket_run).
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
# in it, then removes the worktree. The branch is kept. Run inside that session,
# the window moves to the repo's session first.
_mux_rm() {
  local name=${1:-${NVIM:t:r}} dir parent repo line i
  local sock=$_mux_dir/$name.sock
  for line in ${(f)"$(_mux_sessions)"}; do
    _mux_fields $line
    [[ $reply[1] == $name && -n $reply[4] ]] && { dir=$reply[2] parent=$reply[4] }
  done
  [[ -z $dir ]] && { print -u2 "mux: ${name:-this window} is not a worktree session"; return 1 }
  # git refuses to remove a worktree with changes, so check before stopping anything.
  if [[ -n $(git -C $dir status --porcelain) ]]; then
    print -u2 "mux: $name has uncommitted changes"
    return 1
  fi
  repo=$(git -C $dir rev-parse --path-format=absolute --git-common-dir) || return 1
  repo=${repo:h}
  _mux_kill_procs $sock
  [[ $PWD == $dir(|/*) ]] && cd $repo
  git -C $repo worktree remove $dir || return 1
  print "mux: removed $name; its branch is kept"
  if [[ $NVIM == $sock ]]; then
    # Quitting the server a window is attached to closes the window, so move it
    # to the repo's session and wait until no window is left on this one.
    "${ZSH_CONFIG_DIR:h}/scripts/mux.sh" $parent
    for i in {1..200}; do
      [[ $(command nvim --headless --server $sock --remote-expr 'len(nvim_list_uis())' </dev/null 2>/dev/null) == 0 ]] && break
      sleep 0.05
    done
  fi
  # Run inside that session, this ends this shell.
  _mux_quit $sock &>/dev/null
  return 0
}

# fzf list of the sessions in mux/defs.lua; ▶ marks the one this window is on
# and ● the other running ones. The preview shows the folder's git state.
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
# branch (local or on origin) is checked out; a new one starts from [base] on
# upstream (or origin when there is no upstream), by default that remote's
# default branch. Sets REPLY to the new session's name and reply to its folder.
_mux_worktree() {
  local branch=$1 base=$2 repo dir name line remote=origin
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
    # In a fork setup origin is the fork, whose base branch can be behind.
    git -C $repo remote get-url upstream &>/dev/null && remote=upstream
    if [[ -z $base ]]; then
      base=$(git -C $repo symbolic-ref --short refs/remotes/$remote/HEAD) || return 1
      base=${base#$remote/}
    fi
    git -C $repo fetch -q $remote $base || return 1
    # --no-track: the branch is pushed under its own name, not to base.
    git -C $repo worktree add --no-track -b $branch $dir/$name $remote/$base || return 1
  fi
  REPLY=$name
  reply=($dir/$name)
}

# Creates a worktree (see _mux_worktree) and switches to its session.
_mux_new() {
  [[ -z $1 ]] && { print -u2 "usage: mux new <branch> [base]"; return 1 }
  _mux_worktree $1 $2 && mux $REPLY
}

# Lowercase words joined by hyphens, at most 30 characters, for branch names.
_mux_slug() {
  setopt local_options extended_glob
  local s=${(L)1//[^A-Za-z0-9]##/-}
  s=${s[1,30]}
  s=${s##-##}
  print -r -- ${s%%-##}
}

# Creates a worktree for a ticket, starts its session without switching to it,
# and runs /ticket <id> with claude in the session's first tab. The window stays
# put, so several tickets, or several ideas for one ticket, can start in a row.
# The ticket is an id (IGN-123) or a URL containing one. Any words after it are
# instructions for the agent, saved to .ticket/notes.md in the worktree, where
# /ticket reads them and writes its plan. The branch and session are
# <id>-<name>, with the name from -n, else a short slug Haiku makes from the
# instructions, else just <id>. -b sets the whole branch name instead.
_mux_ticket() {
  setopt local_options extended_glob
  local usage="usage: mux ticket <id or URL> [-n name | -b branch] [instructions...]"
  local id branch label name notes err
  # Only the id and the session name go into the quoted nvim expression below,
  # so both must be plain.
  [[ ${(U)1} =~ '(^|/)([A-Z][A-Z0-9]*-[0-9]+)(/|$)' ]] && id=$match[2]
  [[ -z $id ]] && { print -u2 $usage; return 1 }
  shift
  while [[ $1 == -[bn] ]]; do
    [[ -z $2 ]] && { print -u2 $usage; return 1 }
    [[ $1 == -b ]] && branch=$2 || label=$(_mux_slug $2)
    shift 2
  done
  notes="$*"
  if [[ -z $branch && -z $label && -n $notes ]]; then
    print "mux: naming the branch..."
    label=$(_mux_slug "$(command claude -p --model haiku \
      "Reply with only a 1 to 3 word name for a git branch doing this work, nothing else: $notes" 2>/dev/null)")
  fi
  [[ -z $branch ]] && branch=$id${label:+-$label}
  _mux_worktree $branch || return 1
  name=$REPLY
  if [[ $name != [A-Za-z0-9._-]## ]]; then
    print -u2 "mux: session name $name has characters mux ticket can't pass on"
    return 1
  fi
  # info/exclude, not .gitignore: it keeps .ticket out of every worktree's
  # commits without changing a tracked file.
  local exclude=$(git -C $reply[1] rev-parse --path-format=absolute --git-common-dir)/info/exclude
  grep -qx '/.ticket/' $exclude 2>/dev/null || print '/.ticket/' >> $exclude
  if [[ -n $notes ]]; then
    mkdir -p $reply[1]/.ticket && print -r -- $notes > $reply[1]/.ticket/notes.md || return 1
  fi
  _mux_ensure $name || return 1
  err=$(command nvim --headless --server $_mux_dir/$name.sock \
    --remote-expr "v:lua.require'mux'.send('claude --permission-mode auto -n $name \"/ticket $id\"')" </dev/null 2>&1)
  [[ -n $err ]] && { print -u2 "mux: $name: $err"; return 1 }
  print "mux: started /ticket $id in session $name"
}

# Opens the /ticket plan of session <name>'s folder in nvim, by default the
# plan of the git worktree this shell is in.
_mux_plan() {
  local dir line
  if [[ -n $1 ]]; then
    for line in ${(f)"$(_mux_sessions)"}; do
      _mux_fields $line
      [[ $reply[1] == $1 ]] && dir=$reply[2]
    done
    [[ -z $dir ]] && { print -u2 "mux: no session named $1"; return 1 }
  else
    dir=$(git rev-parse --show-toplevel 2>/dev/null) || { print -u2 "mux: not in a git worktree"; return 1 }
  fi
  [[ -f $dir/.ticket/plan.md ]] || { print -u2 "mux: no plan in $dir"; return 1 }
  command nvim $dir/.ticket/plan.md
}

# Runs /ticket <sub> in worktree session <name> (default: this window's), where
# sub is revise (address the draft PR's review) or test (build a test project
# and tags in the worktree's gateway-launcher). It types into the first tab,
# where mux ticket started claude. A claude still open there is cleared first,
# so the run works from the plan file and the PR, not the old conversation. The
# window stays put.
_mux_ticket_run() {
  setopt local_options extended_glob
  local sub=$1 name=${2:-${NVIM:t:r}} dir line state fg err text
  local -a texts
  for line in ${(f)"$(_mux_sessions)"}; do
    _mux_fields $line
    [[ $reply[1] == $name && -n $reply[4] ]] && dir=$reply[2]
  done
  [[ -z $dir ]] && { print -u2 "mux: ${name:-this window} is not a worktree session"; return 1 }
  # The name goes into the quoted nvim expression below, so it must be plain.
  [[ $name == [A-Za-z0-9._-]## ]] || { print -u2 "mux: session name $name has characters mux $sub can't pass on"; return 1 }
  # Typing into a claude that is still working would interrupt it.
  state=$(grep -m1 '^Status:' $dir/.ticket/plan.md 2>/dev/null)
  if [[ $state != 'Status: pr-open' ]]; then
    print -u2 "mux: $name has no draft PR open yet (${state:-no plan})"
    return 1
  fi
  _mux_ensure $name || return 1
  local sock=$_mux_dir/$name.sock
  fg=$(command nvim --headless --server $sock --remote-expr "v:lua.require'mux'.first_fg()" </dev/null 2>&1)
  case $fg in
  claude) texts=(/clear "/ticket $sub") ;;
  zsh | bash | sh) texts=("claude --permission-mode auto -n $name \"/ticket $sub\"") ;;
  *)
    print -u2 "mux: $name: the first tab runs ${fg:-nothing}, not claude or a shell"
    return 1
    ;;
  esac
  for text in $texts; do
    # /clear has to finish before claude takes the next prompt.
    [[ $text == /ticket* ]] && sleep 1
    err=$(command nvim --headless --server $sock --remote-expr "v:lua.require'mux'.send('$text')" </dev/null 2>&1)
    [[ -n $err ]] && { print -u2 "mux: $name: $err"; return 1 }
  done
  print "mux: started /ticket $sub in session $name"
}

mux() {
  [[ $1 == new ]] && { _mux_new $2 $3; return }
  [[ $1 == revise ]] && { _mux_ticket_run revise $2; return }
  [[ $1 == test ]] && { _mux_ticket_run test $2; return }
  [[ $1 == ticket ]] && { _mux_ticket "${@:2}"; return }
  [[ $1 == plan ]] && { _mux_plan $2; return }
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

_mux() { compadd -- kill new plan restart revise rm test ticket $(_mux_names) }
compdef _mux mux
