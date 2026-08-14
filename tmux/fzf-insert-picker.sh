#!/usr/bin/env bash
# Bound to Ctrl+F in tmux/mappings.conf for any non-vim pane. The pane's foreground process
# (shell, claude, whatever) isn't a shell we can run fzf in directly, so pop it in a floating
# tmux popup instead, then hand the pick to _fzf_insert_picker to type back into that pane.
pane="$1"
# -B: no border/title on the popup itself -- fzf draws its own border-label (same as
# ff/fw/fcd/fr), so an outer title here would just duplicate it.
# Escaping the picker without selecting a file exits fzf non-zero, which would otherwise
# surface as a "returned 1" error banner in tmux's status line -- that's a normal cancel, not
# a failure, so swallow the exit code here.
tmux display-popup -E -B -w 80% -h 70% \
  "zsh -ic '_fzf_insert_picker \"$pane\"'" || true
