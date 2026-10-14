#!/usr/bin/env bash
# Preview for the mux session picker: the session folder's branch, uncommitted changes, and /ticket plan status, kept to local git calls so it shows quickly. Usage: mux-preview.sh <folder>
set -u

DIR=${1:-}
SCRIPTS=$(cd "$(dirname "$0")" && pwd)
cd "$DIR" 2>/dev/null || { echo "Folder not found: $DIR"; exit 1; }
echo "${DIR/#$HOME/~}"
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git symbolic-ref --short -q HEAD)
# Skip gh: a network call would hold up the preview.
base=$(GIT_PR_BASE_SKIP_GH=1 "$SCRIPTS/git-pr-base.sh" 2>/dev/null)
line=${branch:-"detached at $(git rev-parse --short HEAD)"}
if [[ -n "$base" ]]; then
  read -r behind ahead < <(git rev-list --left-right --count "$base...HEAD" 2>/dev/null)
  line+="  ↑${ahead:-?} ↓${behind:-?} $base"
fi
echo "$line"

# -uno: scanning for untracked files is most of git status's time in a large repo.
n=$(git status --short -uno | wc -l | tr -d ' ')
line="$n changed"
# Written by the /ticket skill.
status=$([[ -f .ticket/plan.md ]] && grep -m1 '^Status:' .ticket/plan.md)
[[ -n "$status" ]] && line+=" · plan: ${status#Status: }"
echo "$line"
