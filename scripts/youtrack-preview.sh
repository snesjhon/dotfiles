#!/usr/bin/env bash
# Ticket-detail preview for yt() -- decodes the base64'd JSON blob yt() already fetched, so no API call happens on every focus change.
set -u

BLOB=${1:-}
[[ -n "$BLOB" ]] || exit 1

printf '%s' "$BLOB" | base64 --decode | jq -r '
  "# \(.id)",
  "",
  .summary,
  "",
  "**State:** \(.state)   **Priority:** \(.priority)   **Type:** \(.type)",
  "**Assignee:** \(.assignee)   **Primary Dev:** \(.primaryDev)   **Reporter:** \(.reporter)",
  "",
  "---",
  "",
  .description
' | bat --style=plain --color=always --language=markdown --pager=never
