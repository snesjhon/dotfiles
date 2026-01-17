# Dev directory navigation
dev() {
  local cmd="$1"
  shift

  case "$cmd" in
    cd)
      cd "$HOME/Developer/$1"
      ;;
    *)
      echo "Usage: dev cd <path>"
      ;;
  esac
}

# Tab completion for dev function
_dev() {
  local -a subcommands
  subcommands=('cd:Change to a Developer subdirectory')

  if (( CURRENT == 2 )); then
    _describe 'command' subcommands
  elif (( CURRENT == 3 )) && [[ "$words[2]" == "cd" ]]; then
    _files -W "$HOME/Developer" -/
  fi
}
compdef _dev dev
