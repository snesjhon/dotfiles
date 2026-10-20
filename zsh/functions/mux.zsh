# wt (worktrees, nvim/lua/wt) runs in Lua. `wt --help` lists its commands.

# Runs a Lua command with `nvim -l`, then the step it prints for this shell:
# cd, or open a file in nvim.
_mux_run() {
  local out step arg
  out=$(command nvim -l "$@") || return
  [[ -z $out ]] && return
  step=${out%%$'\t'*} arg=${out#*$'\t'}
  case $step in
  cd) cd $arg ;;
  edit) command nvim $arg ;;
  esac
}

wt() { _mux_run $HOME/.config/nvim/lua/wt/init.lua "$@" }

_wt() {
  if (( CURRENT == 2 )); then
    compadd -- adopt new plan respond revise rm test ticket
  else
    compadd -- $(command nvim -l $HOME/.config/nvim/lua/wt/init.lua names)
  fi
}
compdef _wt wt
