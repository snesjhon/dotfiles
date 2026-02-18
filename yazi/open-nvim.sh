#!/usr/bin/env bash
# Yazi opener: send the file to the main tmux pane instead of opening
# nvim inside yazi's pane. NVIM_BROWSER_MAIN is set by toggle-browser.sh.

file="$1"

if [ -z "$NVIM_BROWSER_MAIN" ]; then
  nvim "$file"
  exit 0
fi

pane="$NVIM_BROWSER_MAIN"
quoted=$(printf '%q' "$file")

current_cmd=$(tmux display-message -p '#{pane_current_command}' -t "$pane" 2>/dev/null | tr -d '[:space:]')

if echo "$current_cmd" | grep -qiE '^n?vim$'; then
  tmux send-keys -t "$pane" Escape
  tmux send-keys -t "$pane" Escape
  sleep 0.05
  tmux send-keys -t "$pane" -l ":e $quoted"
  tmux send-keys -t "$pane" Enter
else
  tmux send-keys -t "$pane" -l "nvim $quoted"
  tmux send-keys -t "$pane" Enter
fi

tmux select-pane -t "$pane"
