#!/bin/bash
# Switches to (or creates) a tmux session and focuses Ghostty. Usage: tmux-session.sh <session-name> <session-path> [window[:path] ...] (a window without ":path" uses session-path as its cwd).

SESSION=$1
SESSION_PATH=$2
shift 2
WINDOWS=("$@")
TMUX_BIN=/opt/homebrew/bin/tmux

window_name() { echo "${1%%:*}"; }
window_path() {
  case "$1" in
    *:*) echo "${1#*:}" ;;
    *) echo "$SESSION_PATH" ;;
  esac
}

if ! $TMUX_BIN has-session -t "$SESSION" 2>/dev/null; then
  if [ ${#WINDOWS[@]} -eq 0 ]; then
    $TMUX_BIN new-session -ds "$SESSION" -c "$SESSION_PATH"
  else
    $TMUX_BIN new-session -ds "$SESSION" -c "$(window_path "${WINDOWS[0]}")" -n "$(window_name "${WINDOWS[0]}")"
    for ((i=1; i<${#WINDOWS[@]}; i++)); do
      $TMUX_BIN new-window -t "$SESSION" -c "$(window_path "${WINDOWS[$i]}")" -n "$(window_name "${WINDOWS[$i]}")"
    done
  fi
fi

$TMUX_BIN switch-client -t "$SESSION"
open -a Ghostty
