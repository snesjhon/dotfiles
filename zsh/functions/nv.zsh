# nv [session] -- attach this terminal to an nvim "mux" session (see
# nvim/lua/sessions.lua): every tab is a shell, like a tmux session with
# windows. Each session is a headless nvim server, so it keeps running when the
# terminal closes. With no argument, pick a session from nvim/lua/session_defs.lua
# with fzf. Inside a session, nv switches that window to another session.
# nv kill -- stop every running mux session, like tmux kill-server.
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

_nv_kill() {
  local sock n=0
  for sock in $_nv_dir/*.sock(N=); do
    if _nv_alive $sock; then
      command nvim --headless --server $sock --remote-send '<Cmd>qa!<CR>' </dev/null 2>/dev/null && (( n++ ))
    else
      rm -f $sock # nothing is listening, so this is a leftover file
    fi
  done
  if (( ! n )); then
    print -u2 "nv: no running sessions"
    return 1
  fi
  print "nv: killed $n session(s)"
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

_nv() { compadd -- kill ${(f)"$(_nv_sessions)"} }
compdef _nv nv
