#!/usr/bin/env bash
# Diff preview for the gp() picker -- shows the file's diff against the PR's base branch, not the working tree.
set -u

FILE=${1:-}
BASE=${2:-}
ROOT=${3:-.}

cd "$ROOT" || exit 1

git diff --color=always "${BASE}...HEAD" -- "$FILE" 2>/dev/null
