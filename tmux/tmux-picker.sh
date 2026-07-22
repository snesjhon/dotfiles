#!/usr/bin/env bash
# Shared launcher for shell-side pickers (yazi's `y`, fzf's `ff`) bound to
# tmux's C-S-y / C-S-f. Single idle window → open in same pane, otherwise
# open in a new window.

if [ "$1" = "--launch" ]; then
  cmd="$2"
  CURRENT_CMD=$(tmux display-message -p '#{pane_current_command}' | tr -d '[:space:]')

  if echo "$CURRENT_CMD" | grep -qiE '^(zsh|bash|fish|sh)$'; then
    tmux send-keys "$cmd" Enter
  else
    tmux new-window "$cmd"
  fi
fi
