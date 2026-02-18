#!/usr/bin/env bash
# When called with --launch (from tmux binding via run-shell):
#   checks if single idle window → opens yazi in same pane
#   otherwise → opens yazi in a new window
# When called directly (in a pane): runs yazi and opens selected file in nvim.

SCRIPT="$HOME/Developer/dotfiles/tmux/tmux-yazi.sh"

if [ "$1" = "--launch" ]; then
  PANE_ID=$(tmux display-message -p '#{pane_id}')
  WINDOW_COUNT=$(tmux list-windows | wc -l | tr -d '[:space:]')
  CURRENT_CMD=$(tmux display-message -p '#{pane_current_command}' | tr -d '[:space:]')

  if [ "$WINDOW_COUNT" -eq 1 ] && echo "$CURRENT_CMD" | grep -qiE '^(zsh|bash|fish|sh)$'; then
    tmux send-keys -t "$PANE_ID" "$SCRIPT" Enter
  else
    tmux new-window "$SCRIPT"
  fi
  exit 0
fi

# Yazi runner: open yazi, then nvim with the chosen file
tmp=$(mktemp -t yazi-chooser)
yazi --chooser-file="$tmp"
file=$(cat "$tmp" 2>/dev/null)
rm -f "$tmp"

[ -n "$file" ] && nvim "$file"
