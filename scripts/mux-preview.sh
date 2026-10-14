#!/usr/bin/env bash
# Preview for the mux session picker: the session folder's branch, changes, recent commits, and PR. Usage: mux-preview.sh <folder>
set -u

DIR=${1:-}
SCRIPTS=$(cd "$(dirname "$0")" && pwd)
cd "$DIR" 2>/dev/null || { echo "Folder not found: $DIR"; exit 1; }
echo "${DIR/#$HOME/~}"
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git symbolic-ref --short -q HEAD)
# Skip gh here: the PR lookup below already pays for one network call.
base=$(GIT_PR_BASE_SKIP_GH=1 "$SCRIPTS/git-pr-base.sh" 2>/dev/null)
line=${branch:-"detached at $(git rev-parse --short HEAD)"}
if [[ -n "$base" ]]; then
  read -r behind ahead < <(git rev-list --left-right --count "$base...HEAD" 2>/dev/null)
  line+="  ↑${ahead:-?} ↓${behind:-?} $base"
fi
echo "$line"
# Written by the /ticket skill.
[[ -f .ticket/plan.md ]] && grep -m1 '^Status:' .ticket/plan.md

echo
changes=$(git -c color.status=always status --short)
if [[ -z "$changes" ]]; then
  echo "No uncommitted changes"
else
  echo "$changes" | head -10
  n=$(echo "$changes" | wc -l)
  (( n > 10 )) && echo "... $((n - 10)) more"
fi

echo
git log --oneline --color=always -5

# The base branch itself has no PR.
[[ -z "$branch" || "$base" == */"$branch" ]] && exit 0
echo
gh pr view --json number,title,isDraft,state,reviewDecision,statusCheckRollup --jq '
  "#\(.number) \(.title)",
  "\(if .isDraft then "Draft" else .state end), review: \(.reviewDecision // "" | if . == "" then "none" else ascii_downcase | gsub("_"; " ") end)",
  "checks: " + ([.statusCheckRollup[] | if (.conclusion // "") != "" then .conclusion else (.state // .status) end | ascii_downcase]
    | group_by(.) | map("\(length) \(.[0])") | join(", ") | if . == "" then "none" else . end)
' 2>/dev/null || echo "No PR"
