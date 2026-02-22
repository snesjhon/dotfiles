#!/bin/bash
# Switch to (or create) a tmux session, then focus Ghostty
# Usage: tmux-session.sh <session-name> <session-path>

SESSION=$1
SESSION_PATH=$2
TMUX=/opt/homebrew/bin/tmux

$TMUX has-session -t "$SESSION" 2>/dev/null \
  || $TMUX new-session -ds "$SESSION" -c "$SESSION_PATH"

$TMUX switch-client -t "$SESSION"
open -a Ghostty
