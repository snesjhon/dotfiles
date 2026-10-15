# review: PR review in nvim

A small replacement for diffview and octo: a file tree, side-by-side diffs, line comments, and one call to submit the review.

## Usage

- `:Review 123` reviews PR #123 (fetches its commits if they aren't local).
- `:Review` reviews the current branch against its PR base (`$GIT_PR_BASE_SCRIPT`).
- `:Review <ref>` reviews the current branch against `<ref>`.

Opens in its own tab. `q` closes it and wipes every buffer it created.

## Layout

```
┌ PR #123 ─────┬ base ───────────────┬ head ───────────────┐
│ ▾ src/       │                     │                     │
│   M foo.ts 2 │   (native diff      │ ▎ line with comment │
│ ✓ A bar.ts   │    highlights)      │   ┃ your comment     │
└──────────────┴─────────────────────┴─────────────────────┘
```

## Modules

- `init.lua`: `open`/`close`, session state, shared keymaps.
- `git.lua`: changed files, file content at a commit, merge-base, hunk ranges.
- `gh.lua`: PR metadata, submit review.
- `tree.lua`: file panel.
- `diff.lua`: the two diff panes. Read-only scratch buffers filled from `git show`, compared with `:diffthis`.
- `comments.lua`: add/edit/delete, inline display, saved to `<git-common-dir>/review/<pr>.json` so every worktree shares one review.
- `ui.lua`: comment float (`:w` saves, `q` cancels). The picker lands here in phase 3.

## State

```lua
state = {
  pr = { number, repo, title },
  base, head,     -- base is the merge-base sha, same diff GitHub shows
  files = { { path, old_path, status, bufs, lines, hunks = { LEFT = {}, RIGHT = {} }, viewed } },
  comments = { { path, side, line, start_line, body } },
}
```

## Keymaps

| Where | Key | Action |
|---|---|---|
| Anywhere | `]f` / `[f` | Next/prev file |
| Anywhere | `q` | Close |
| Anywhere | `L` | Picker of all your comments (phase 3) |
| Anywhere | `S` | Submit review (phase 3) |
| Tree | `<CR>` | Open file |
| Tree | `x` | Toggle viewed (phase 4) |
| Diff | `]c` / `[c` | Next/prev hunk (native) |
| Diff | `c` (normal or visual) | Comment on the line or range |
| Diff | `e` / `dc` | Edit / delete the comment under the cursor (saving an empty edit also deletes) |

## Phases

1. **Diff viewer.** Tree, panes, file navigation, close. Replaces diffview and `:PrDiff`.
2. **Comments.** Add, edit, delete, save to disk, inline display, counts in the tree. Comments outside a hunk are rejected when written, since GitHub returns a 422 for the whole review otherwise. Hunk ranges come from `git diff -U3` headers.
3. **List and submit.** Snacks picker over the comments. Submit is one `gh api POST repos/{repo}/pulls/{n}/reviews` with `commit_id`, `event`, `body`, and every comment. Warn if the PR head moved since loading. Clear the saved file once it succeeds.
4. **Extras.** Viewed marks, the real file on the right when the PR is checked out and clean (so LSP works), other people's comments shown read-only, a `mux review` launcher.

## Comment display

Comments show as a sign on their lines and virtual lines under the last one. Diff mode doesn't count virtual lines when it lines up the panes, so the other pane gets the same number of blank virtual lines at the matching line (found with `vim.text.diff`, the engine `:diffthis` uses).

## Known limits

- Git calls block. They're fast for single files, but fetching a PR can take a few seconds.
- Binary files show a placeholder line instead of a diff.
