#!/usr/bin/env bash
# ctrl-p handler for yt() -- checks out the issue's PR via `gh` in yt()'s cwd, writing the outcome to $2 since the picker aborts (and can't show a header) right after.
set -u

ID=${1%% *}
STATUS_FILE=${2:-}

report() {
  [[ -n "$STATUS_FILE" ]] && printf '%s\n' "$1" > "$STATUS_FILE"
}

if [[ -z "$ID" || -z "${YOUTRACK_GH_HOST:-}" || -z "${YOUTRACK_GH_REPO:-}" ]]; then
  echo 'change-header(-- set YOUTRACK_GH_HOST/YOUTRACK_GH_REPO to look up PRs --)'
  exit 0
fi

pr_url=$(GH_HOST="$YOUTRACK_GH_HOST" gh pr list --repo "$YOUTRACK_GH_REPO" \
  --search "$ID in:title" --state all \
  --json url --jq '.[0].url // empty' 2>/dev/null)

if [[ -z "$pr_url" ]]; then
  report "yt: no PR found for $ID"
elif GH_HOST="$YOUTRACK_GH_HOST" gh pr checkout "$pr_url" >/dev/null 2>&1; then
  report "yt: checked out PR for $ID"
else
  report "yt: failed to check out PR for $ID (dirty tree?)"
fi

echo 'abort'
