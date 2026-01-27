# Dev directory navigation and script runner
dev() {
  local cmd="$1"
  shift

  case "$cmd" in
    cd)
      cd "$HOME/Developer/$1"
      ;;
    run)
      local script_name="$1"
      shift
      local script_path="$HOME/Developer/dotfiles/scripts/${script_name}.sh"

      if [[ -z "$script_name" ]]; then
        echo "Available scripts:"
        ls -1 "$HOME/Developer/dotfiles/scripts" | sed 's/\.sh$//'
        return 1
      fi

      if [[ ! -f "$script_path" ]]; then
        echo "Error: Script '$script_name' not found in scripts directory"
        echo "Available scripts:"
        ls -1 "$HOME/Developer/dotfiles/scripts" | sed 's/\.sh$//'
        return 1
      fi

      "$script_path" "$@"
      ;;
    *)
      echo "Usage:"
      echo "  dev cd <path>        - Change to a Developer subdirectory"
      echo "  dev run <script>     - Run a script from dotfiles/scripts"
      ;;
  esac
}

# Tab completion for dev function
_dev() {
  local -a subcommands
  subcommands=(
    'cd:Change to a Developer subdirectory'
    'run:Run a script from dotfiles/scripts'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' subcommands
  elif (( CURRENT == 3 )); then
    case "$words[2]" in
      cd)
        _files -W "$HOME/Developer" -/
        ;;
      run)
        local -a scripts
        scripts=(${(f)"$(ls -1 $HOME/Developer/dotfiles/scripts/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//')"})
        _describe 'script' scripts
        ;;
    esac
  fi
}
compdef _dev dev
