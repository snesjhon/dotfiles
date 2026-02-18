#!/usr/bin/env bash
# Toggle a right-side file browser pane (nvim + neo-tree).
# C-a e: open/focus browser; C-a e again from inside browser: close it.

CURRENT_PANE=$(tmux display-message -p '#{pane_id}')
BROWSER_PANE=$(tmux show-option -w -qv "@browser-pane")

pane_exists() {
  tmux list-panes -F '#{pane_id}' 2>/dev/null | grep -q "^${1}$"
}

if [ -n "$BROWSER_PANE" ] && pane_exists "$BROWSER_PANE"; then
  if [ "$CURRENT_PANE" = "$BROWSER_PANE" ]; then
    # Already in browser — close it and return to main pane
    MAIN_PANE=$(tmux show-option -w -qv "@browser-main-pane")
    tmux kill-pane -t "$BROWSER_PANE"
    tmux set-option -w -u "@browser-pane"
    tmux set-option -w -u "@browser-main-pane"
    if [ -n "$MAIN_PANE" ] && pane_exists "$MAIN_PANE"; then
      tmux select-pane -t "$MAIN_PANE"
    fi
  else
    # Browser exists but not focused — focus it
    tmux select-pane -t "$BROWSER_PANE"
  fi
else
  # No browser pane — create one on the right (40 cols, same cwd)
  BROWSER_PANE=$(tmux split-window -h -l 40 \
    -c "#{pane_current_path}" \
    -P -F '#{pane_id}' \
    "NVIM_BROWSER_MAIN=$CURRENT_PANE yazi")
  tmux set-option -w "@browser-pane" "$BROWSER_PANE"
  tmux set-option -w "@browser-main-pane" "$CURRENT_PANE"
fi
