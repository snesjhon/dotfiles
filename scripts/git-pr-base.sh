#!/usr/bin/env bash
# Resolves the PR base branch for gp(), :PrFiles, and starship -- tries an explicit override, then `gh`'s PR base, then
# the PR this branch was actually fetched from (if any), then the branch's own reflog, else the default branch,
# printing whichever remote (that PR's fork, then upstream, then origin) actually has it.
set -u

OVERRIDE=${1:-}
ROOT=${2:-.}

cd "$ROOT" || exit 1

# Prints "host/owner/repo" for a remote, from either an ssh or https URL, so
# `gh --repo` can be pointed at enterprise hosts as well as github.com.
remote_repo() {
  local url
  url=$(git remote get-url "$1" 2>/dev/null) || return 1
  url="${url%.git}"
  local host owner_repo
  case "$url" in
  git@*)
    host="${url#git@}"
    host="${host%%:*}"
    owner_repo="${url#*:}"
    ;;
  ssh://*)
    owner_repo="${url#ssh://}"
    owner_repo="${owner_repo#*@}"
    host="${owner_repo%%/*}"
    owner_repo="${owner_repo#*/}"
    ;;
  https://* | http://*)
    owner_repo="${url#*://}"
    host="${owner_repo%%/*}"
    owner_repo="${owner_repo#*/}"
    ;;
  *) return 1 ;;
  esac
  echo "${host}/${owner_repo}"
}

base=""
base_remote=""

[[ -z "$OVERRIDE" ]] || base="$OVERRIDE"
[[ -z "$base" && -z "${GIT_PR_BASE_SKIP_GH:-}" ]] && base=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null)

branch=$(git symbolic-ref --short -q HEAD)

# `gh pr checkout` (or a bare `git fetch <remote> refs/pull/<N>/head:<branch>`)
# can leave branch.<name>.remote pointing at the PR head's own fork instead of
# the fork the PR was opened on -- or at nothing usable -- so the plain
# `gh pr view` above finds nothing for cross-fork PRs. The reflog still names
# the remote and PR number the branch was actually fetched from; ask `gh`
# about that PR/repo directly instead of trusting branch config.
if [[ -z "$base" && -n "$branch" && -z "${GIT_PR_BASE_SKIP_GH:-}" ]]; then
  pr_fetch=$(git reflog show --format='%gs' "$branch" 2>/dev/null | grep -m1 -E '^fetch [^ ]+ refs/pull/[0-9]+/head:')
  if [[ -n "$pr_fetch" ]]; then
    pr_remote="${pr_fetch#fetch }"
    pr_remote="${pr_remote%% *}"
    pr_number="${pr_fetch#*refs/pull/}"
    pr_number="${pr_number%%/*}"
    pr_repo=$(remote_repo "$pr_remote")
    if [[ -n "$pr_repo" ]]; then
      base=$(gh pr view "$pr_number" --repo "$pr_repo" --json baseRefName -q .baseRefName 2>/dev/null)
      if [[ -n "$base" ]]; then
        base_remote="$pr_remote"
        # The fork's own base branch is rarely fetched otherwise -- refresh it
        # so the diff lands on the actual PR fork-point, not a stale one.
        git fetch --quiet "$pr_remote" "$base" 2>/dev/null
      fi
    fi
  fi
fi

if [[ -z "$base" && -n "$branch" ]]; then
  reflog_subject=$(git reflog show --format='%gs' "$branch" 2>/dev/null | tail -1)
  if [[ "$reflog_subject" == 'branch: Created from '* ]]; then
    reflog_ref="${reflog_subject#branch: Created from }"
    [[ "$reflog_ref" == */* ]] && base="${reflog_ref#*/}"
  fi
fi

if [[ -z "$base" ]]; then
  for remote in upstream origin; do
    base=$(git symbolic-ref --short "refs/remotes/${remote}/HEAD" 2>/dev/null)
    [[ -n "$base" ]] && {
      base="${base#${remote}/}"
      break
    }
  done
fi
[[ -z "$base" ]] && base='main'

for remote in "$base_remote" upstream origin; do
  [[ -z "$remote" ]] && continue
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
