#!/usr/bin/env bash
# Diff preview for the gd() picker (zsh/functions/fzf-pickers.zsh). Takes the
# plain (hidden, tab-delimited) path field fzf hands back -- no status code
# needed: an untracked file just has no `git diff HEAD` output, so that's
# what decides whether to fall back to the /dev/null "whole file as added" diff.
set -u

FILE=${1:-}
ROOT=${2:-.}

cd "$ROOT" || exit 1

out=$(git diff HEAD --color=always -- "$FILE" 2>/dev/null)
if [[ -n "$out" ]]; then
  printf '%s\n' "$out"
else
  git diff --no-index --color=always -- /dev/null "$FILE" 2>/dev/null
fi
