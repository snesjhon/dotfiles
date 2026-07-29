#!/usr/bin/env bash
# ctrl-o handler for yt() -- runs as an fzf transform so the picker stays open, reporting the PR lookup/open outcome via a change-header on stdout.
set -u

ID=${1%% *}
if [[ -z "$ID" || -z "${YOUTRACK_GH_HOST:-}" || -z "${YOUTRACK_GH_REPO:-}" ]]; then
  echo 'change-header(-- set YOUTRACK_GH_HOST/YOUTRACK_GH_REPO to look up PRs --)'
  exit 0
fi

pr_url=$(GH_HOST="$YOUTRACK_GH_HOST" gh pr list --repo "$YOUTRACK_GH_REPO" \
  --search "$ID in:title" --state all \
  --json url --jq '.[0].url // empty' 2>/dev/null)

if [[ -n "$pr_url" ]]; then
  open "$pr_url"
  echo "change-header(-- opened PR for $ID --)"
else
  echo "change-header(-- no PR found for $ID --)"
fi
