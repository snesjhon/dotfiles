# mux (sessions, nvim/lua/mux/cli.lua) and wt (worktrees, nvim/lua/wt) run in
# Lua. `mux --help` and `wt --help` list their commands.

# Runs a Lua command with `nvim -l`, then the step it prints for this shell:
# attach this terminal to a session, cd, or open a file in nvim.
_mux_run() {
  local out step arg
  out=$(command nvim -l "$@") || return
  [[ -z $out ]] && return
  step=${out%%$'\t'*} arg=${out#*$'\t'}
  case $step in
  attach) command nvim --remote-ui --server $arg ;;
  cd) cd $arg ;;
  edit) command nvim $arg ;;
  esac
}

mux() { _mux_run $HOME/.config/nvim/lua/mux/cli.lua "$@" }
wt() { _mux_run $HOME/.config/nvim/lua/wt/init.lua "$@" }

_mux() { compadd -- kill restart $(command nvim -l $HOME/.config/nvim/lua/mux/cli.lua names) }
_wt() {
  if (( CURRENT == 2 )); then
    compadd -- adopt new plan respond revise rm test ticket
  else
    compadd -- $(command nvim -l $HOME/.config/nvim/lua/wt/init.lua names)
  fi
}
compdef _mux mux
compdef _wt wt
