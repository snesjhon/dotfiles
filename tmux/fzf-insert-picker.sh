#!/usr/bin/env bash

pane="$1"

tmux display-popup -E -B -w 80% -h 70% \
  "zsh -ic '_fzf_insert_picker \"$pane\"'" || true
