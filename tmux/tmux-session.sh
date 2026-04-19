#!/bin/bash
# Switch to (or create) a tmux session, then focus Ghostty
# Usage: tmux-session.sh <session-name> <session-path> [window-name ...]
# Example: tmux-session.sh myapp ~/projects/myapp code agent server

SESSION=$1
SESSION_PATH=$2
shift 2
WINDOWS=("$@")
TMUX=/opt/homebrew/bin/tmux

if ! $TMUX has-session -t "$SESSION" 2>/dev/null; then
  if [ ${#WINDOWS[@]} -eq 0 ]; then
    $TMUX new-session -ds "$SESSION" -c "$SESSION_PATH"
  else
    $TMUX new-session -ds "$SESSION" -c "$SESSION_PATH" -n "${WINDOWS[0]}"
    for ((i=1; i<${#WINDOWS[@]}; i++)); do
      $TMUX new-window -t "$SESSION" -c "$SESSION_PATH" -n "${WINDOWS[$i]}"
    done
  fi
fi

$TMUX switch-client -t "$SESSION"
open -a Ghostty
