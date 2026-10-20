# dev cd <path> -- cd to a folder under ~/Developer
dev() {
  case "$1" in
    cd) cd "$HOME/Developer/$2" ;;
    *) echo "Usage: dev cd <path>" ;;
  esac
}

_dev() {
  if (( CURRENT == 2 )); then
    compadd cd
  elif (( CURRENT == 3 )) && [[ $words[2] == cd ]]; then
    _files -W "$HOME/Developer" -/
  fi
}
compdef _dev dev
