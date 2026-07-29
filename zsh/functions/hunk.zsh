# Terminal counterpart to vim's :HunkShow (see vim/plugins/hunk.vim) -- single-letter
# launcher, like yazi's `y`, bound to `hunk diff` against the PR's resolved base (same
# git-pr-base.sh resolution gp()/:PrDiff share) rather than bare working-tree changes.
# Optional $1 overrides the base branch, same convention as gp().
h() {
	local root base
	root=$(git rev-parse --show-toplevel 2>/dev/null) || { print -u2 "h: not a git repository"; return 1 }
	base=$("$GIT_PR_BASE_SCRIPT" "${1:-}" "$root" 2>&1) || { print -u2 "h: $base"; return 1 }
	command hunk diff "${base}...HEAD"
}
