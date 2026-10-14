# mux [session] -- attach this terminal to an nvim session (see
# nvim/lua/mux): every tab is a shell. Each session is a headless nvim
# server, so it keeps running when the terminal closes. With no argument, pick a
# session from nvim/lua/mux/defs.lua with fzf. Inside a session, mux switches that window to another session.
# mux restart -- reload the nvim config in every running session; shells keep running.
# mux kill -- stop every process in the sessions' shells, then quit the sessions.

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

# Quit every session's server. Each shell gets a hangup, but anything that
# outlives it (background jobs, tools that ignore the hangup) keeps running.
_mux_quit() {
  local sock own n=0
  for sock in $_mux_dir/*.sock(N=); do
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

# Stop every process on the sessions' ptys and their children (which catches
# ones that moved off the pty), then quit the servers.
_mux_kill() {
  local sock pty p pp i n=0 pids=() queue=() alive=()
  local -A kids
  ps -A -o pid=,ppid= | while read p pp; do kids[$pp]+=" $p"; done
  for sock in $_mux_dir/*.sock(N=); do
    _mux_alive $sock || continue
    (( n++ ))
    for pty in ${(f)"$(command nvim --headless --server $sock --remote-expr "v:lua.require'mux'.ptys()" </dev/null 2>/dev/null)"}; do
      queue+=(${=$(ps -o pid= -t ${pty:t})})
    done
  done
  if (( ! n )); then
    print -u2 "mux: no running sessions"
    return 1
  fi
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
  print "mux: killed $n session(s) and $#pids process(es)"
  # A session quits by itself once its last shell exits, so this only catches the rest.
  _mux_quit &>/dev/null
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

mux() {
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

_mux() { compadd -- kill restart $(_mux_names) }
compdef _mux mux
