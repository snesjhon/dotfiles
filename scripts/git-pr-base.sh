#!/usr/bin/env bash
# Resolves the PR base branch for gp(), :PrFiles, and starship -- tries an explicit override, then `gh`'s PR base, then the branch's own reflog, else the default branch, printing whichever remote (upstream over origin) actually has it.
set -u

OVERRIDE=${1:-}
ROOT=${2:-.}

cd "$ROOT" || exit 1

base="$OVERRIDE"
[[ -z "$base" && -z "${GIT_PR_BASE_SKIP_GH:-}" ]] && base=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null)

if [[ -z "$base" ]]; then
  branch=$(git symbolic-ref --short -q HEAD)
  if [[ -n "$branch" ]]; then
    reflog_subject=$(git reflog show --format='%gs' "$branch" 2>/dev/null | tail -1)
    if [[ "$reflog_subject" == 'branch: Created from '* ]]; then
      reflog_ref="${reflog_subject#branch: Created from }"
      [[ "$reflog_ref" == */* ]] && base="${reflog_ref#*/}"
    fi
  fi
fi

if [[ -z "$base" ]]; then
  for remote in upstream origin; do
    base=$(git symbolic-ref --short "refs/remotes/${remote}/HEAD" 2>/dev/null)
    [[ -n "$base" ]] && { base="${base#${remote}/}"; break; }
  done
fi
[[ -z "$base" ]] && base='main'

for remote in upstream origin; do
  if git rev-parse --verify -q "${remote}/${base}" >/dev/null 2>&1; then
    echo "${remote}/${base}"
    exit 0
  fi
done

if git rev-parse --verify -q "$base" >/dev/null 2>&1; then
  echo "$base"
  exit 0
fi

echo "couldn't resolve base branch '${base}'" >&2
exit 1
