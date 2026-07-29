#!/usr/bin/env bash
# Diff preview for the gd() picker -- falls back to a /dev/null "whole file as added" diff when `git diff HEAD` has no output (untracked files).
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
