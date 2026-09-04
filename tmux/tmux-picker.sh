#!/usr/bin/env bash
# Shared launcher for shell-side pickers (yazi/fzf) bound to tmux's C-S-y/C-S-n -- reuses an idle window or opens a new one.

if [ "$1" = "--launch" ]; then
  cmd="$2"
  CURRENT_CMD=$(tmux display-message -p '#{pane_current_command}' | tr -d '[:space:]')

  # Passing $cmd directly as new-window's argument runs it as a one-shot non-interactive
  # shell command, which never sources zshrc -- so `y`/`ff` are undefined ("command
  # not found") and the window closes before you can see it. Always land in a real
  # interactive shell first, then send-keys the command into it, same as the reused-pane path.
  if ! echo "$CURRENT_CMD" | grep -qiE '^(zsh|bash|fish|sh)$'; then
    tmux new-window
  fi
  tmux send-keys "$cmd" Enter
fi
