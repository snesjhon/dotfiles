# nv [session] -- attach this terminal to an nvim "mux" session (see
# nvim/lua/sessions.lua): every tab is a shell. Each session is a headless nvim
# server, so it keeps running when the terminal closes. With no argument, pick a
# session from nvim/lua/session_defs.lua with fzf. Inside a session, nv switches that window to another session.
# nv restart -- reload the nvim config in every running session; shells keep running.
# nv kill -- stop every process in the sessions' shells, then quit the sessions.
_nv_sessions() {
  # io.stdout, not print: `nvim -l` sends print() to stderr.
  command nvim --clean -l <(print -r 'for k in pairs(dofile(_G.arg[1])) do io.stdout:write(k, "\n") end') \
    "$HOME/.config/nvim/lua/session_defs.lua"
}

_nv_dir=${TMPDIR:-/tmp}
_nv_dir=${_nv_dir%/}/nv-sessions

# --headless and no stdin: from inside a terminal buffer a plain nvim client
# starts a TUI first (escape codes, waits on the terminal), which is slow.
_nv_alive() { command nvim --headless --server $1 --remote-expr 1 </dev/null &>/dev/null }

# Start the session's server if it isn't running, and wait until it answers.
_nv_ensure() {
  local sock=$_nv_dir/$1.sock i
  _nv_alive $sock && return
  rm -f $sock
  mkdir -p $_nv_dir
  # &! detaches the server from this shell so closing the terminal doesn't stop it.
  command nvim --headless --listen $sock --cmd 'let g:mux = 1' +"Session $1" &>/dev/null &!
  for i in {1..100}; do
    _nv_alive $sock && return
    sleep 0.05
  done
  print -u2 "nv: session $1 did not start"
  return 1
}

# Re-run the nvim config in every running session (see reload in sessions.lua).
_nv_restart() {
  local sock err n=0
  for sock in $_nv_dir/*.sock(N=); do
    _nv_alive $sock || continue
    err=$(command nvim --headless --server $sock --remote-expr "v:lua.require'sessions'.reload()" </dev/null 2>&1)
    if [[ -n $err ]]; then
      print -u2 "nv: ${sock:t:r}: $err"
    else
      (( n++ ))
    fi
  done
  if (( ! n )); then
    print -u2 "nv: no sessions reloaded"
    return 1
  fi
  print "nv: reloaded config in $n session(s)"
}

# Quit every session's server. Each shell gets a hangup, but anything that
# outlives it (background jobs, tools that ignore the hangup) keeps running.
_nv_quit() {
  local sock own n=0
  for sock in $_nv_dir/*.sock(N=); do
    if _nv_alive $sock; then
      # Run inside a session, quitting its own server ends this shell, so that one goes last.
      [[ $sock == $NVIM ]] && { own=$sock; (( n++ )); continue }
      command nvim --headless --server $sock --remote-send '<Cmd>qa!<CR>' </dev/null 2>/dev/null && (( n++ ))
    else
      rm -f $sock # nothing is listening, so this is a leftover file
    fi
  done
  if (( ! n )); then
    print -u2 "nv: no running sessions"
    return 1
  fi
  print "nv: stopped $n session(s)"
  [[ -n $own ]] && command nvim --headless --server $own --remote-send '<Cmd>qa!<CR>' </dev/null 2>/dev/null
  return 0
}

# Stop every process on the sessions' ptys and their children (which catches
# ones that moved off the pty), then quit the servers.
_nv_kill() {
  local sock pty p pp i n=0 pids=() queue=() alive=()
  local -A kids
  ps -A -o pid=,ppid= | while read p pp; do kids[$pp]+=" $p"; done
  for sock in $_nv_dir/*.sock(N=); do
    _nv_alive $sock || continue
    (( n++ ))
    for pty in ${(f)"$(command nvim --headless --server $sock --remote-expr "v:lua.require'sessions'.ptys()" </dev/null 2>/dev/null)"}; do
      queue+=(${=$(ps -o pid= -t ${pty:t})})
    done
  done
  if (( ! n )); then
    print -u2 "nv: no running sessions"
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
  print "nv: killed $n session(s) and $#pids process(es)"
  # A session quits by itself once its last shell exits, so this only catches the rest.
  _nv_quit &>/dev/null
  return 0
}

# fzf list of the sessions in session_defs.lua; ▶ marks the one this window is on.
_nv_pick() {
  local name current=${NVIM:t:r}
  for name in ${(o)${(f)"$(_nv_sessions)"}}; do
    [[ $name == $current ]] && print "▶ $name" || print "  $name"
  done | fzf --height 40% --border-label ' Sessions ' --border-label-pos 2 | awk '{print $NF}'
}

nv() {
  [[ $1 == kill ]] && { _nv_kill; return }
  [[ $1 == restart ]] && { _nv_restart; return }
  local name=$1
  [[ -z $name ]] && name=$(_nv_pick)
  [[ -z $name ]] && return
  if [[ -n $NVIM ]]; then
    # Moving the window to another session has to run from the UI's own input,
    # which a shell can't send. nv-session.sh presses a key that nvim maps to it.
    "${ZSH_CONFIG_DIR:h}/scripts/nv-session.sh" $name
    return
  fi
  _nv_ensure $name || return 1
  command nvim --remote-ui --server $_nv_dir/$name.sock
}

_nv() { compadd -- kill restart ${(f)"$(_nv_sessions)"} }
compdef _nv nv
