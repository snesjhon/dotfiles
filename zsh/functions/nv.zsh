# nv [session] -- start an nvim "mux" session (see nvim/lua/sessions.lua):
# every tab is a shell, like a tmux session with windows. With no argument,
# pick a session from nvim/lua/session_defs.lua with fzf.
# nv kill -- terminate every running mux session, like tmux kill-server.
_nv_sessions() {
  command nvim --clean -l <(print 'for k in pairs(dofile(_G.arg[1])) do print(k) end') \
    "$HOME/.config/nvim/lua/session_defs.lua"
}

_nv_dir=${TMPDIR:-/tmp}/nv-sessions

_nv_kill() {
  local sock pid n=0
  # Preferred: ask each session to quit over its socket. SIGTERM works but makes
  # nvim print "Caught deadly signal" in the parent terminal.
  for sock in $_nv_dir/*(N=); do
    if command nvim --server $sock --remote-send '<Cmd>qa!<CR>' 2>/dev/null; then
      (( n++ ))
    else
      rm -f $sock # stale, its nvim is gone
    fi
  done
  # Fallback for sessions started without a socket. ps because pgrep doesn't
  # list these processes on macOS; the --embed server exits with its client.
  for pid in ${(f)"$(ps -axo pid=,command= | awk '/nvim .*--cmd let g:mux = 1/ && !/--embed/ && !/--listen/ && !/awk/ {print $1}')"}; do
    kill $pid && (( n++ ))
  done
  if (( ! n )); then
    print -u2 "nv: no running sessions"
    return 1
  fi
  print "nv: killed $n session(s)"
}

nv() {
  [[ $1 == kill ]] && { _nv_kill; return }
  if [[ -n $NVIM ]]; then
    print -u2 "nv: already inside nvim"
    return 1
  fi
  local name=$1
  [[ -z $name ]] && name=$(_nv_sessions | fzf --height 40% --reverse --prompt 'session> ')
  [[ -z $name ]] && return
  mkdir -p $_nv_dir
  local sock=$_nv_dir/$name-$$.sock
  command nvim --listen $sock --cmd 'let g:mux = 1' +"Session $name"
  rm -f $sock
}

_nv() { compadd -- kill ${(f)"$(_nv_sessions)"} }
compdef _nv nv
