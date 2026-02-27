#!/usr/bin/env bash
# ctrl-a e: open yazi.
# Single idle window → open in same pane, otherwise open in a new window.

if [ "$1" = "--launch" ]; then
  CURRENT_CMD=$(tmux display-message -p '#{pane_current_command}' | tr -d '[:space:]')

  if echo "$CURRENT_CMD" | grep -qiE '^(zsh|bash|fish|sh)$'; then
    tmux send-keys "yazi" Enter
  else
    tmux new-window "yazi"
  fi
fi
