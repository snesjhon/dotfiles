# nv [session] -- start an nvim "mux" session (see nvim/lua/sessions.lua):
# every tab is a shell, like a tmux session with windows. With no argument,
# pick a session from nvim/lua/session_defs.lua with fzf.
_nv_sessions() {
  command nvim --clean -l <(print 'for k in pairs(dofile(_G.arg[1])) do print(k) end') \
    "$HOME/.config/nvim/lua/session_defs.lua"
}

nv() {
  if [[ -n $NVIM ]]; then
    print -u2 "nv: already inside nvim"
    return 1
  fi
  local name=$1
  [[ -z $name ]] && name=$(_nv_sessions | fzf --height 40% --reverse --prompt 'session> ')
  [[ -z $name ]] && return
  command nvim --cmd 'let g:mux = 1' +"Session $name"
}

_nv() { compadd -- ${(f)"$(_nv_sessions)"} }
compdef _nv nv
