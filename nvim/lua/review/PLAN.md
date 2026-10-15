# review: PR review in nvim

A small replacement for diffview and octo: a file tree, side-by-side diffs, line comments, and one call to submit the review.

## Usage

- `:Review 123` reviews PR #123 (fetches its commits if they aren't local).
- `:Review` reviews the current branch's PR. With no PR, it reviews the branch against its PR base (`$GIT_PR_BASE_SCRIPT`) and comments stay as local notes, then move to the PR the first time it's reviewed.
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
- `gh.lua`: PR metadata, the submit API call.
- `submit.lua`: the submit flow (head check, review type, summary).
- `tree.lua`: file panel.
- `diff.lua`: the two diff panes. Read-only scratch buffers filled from `git show`, compared with `:diffthis`.
- `comments.lua`: add/edit/delete, inline display (yours and other people's), the comment picker.
- `store.lua`: comments and viewed marks, saved to `<git-common-dir>/review/<key>.json` so every worktree shares one review.
- `remote.lua`: other people's review comments, fetched in the background and shown read-only.
- `ui.lua`: comment float (`:w` saves, `q` cancels).

## State

```lua
state = {
  pr = { number, host, repo, title },
  base, head,     -- base is the merge-base sha, same diff GitHub shows
  files = { { path, old_path, status, bufs, lines, hunks = { LEFT = {}, RIGHT = {} }, viewed } },
  comments = { { path, side, line, start_line, body } },
}
```

## Keymaps

| Where | Key | Action |
|---|---|---|
| Anywhere | `.` / `,` | Next/prev file |
| Anywhere | `e` | Open the file in the tab the review started from (at the matching line from a diff pane) |
| Anywhere | `q` | Close |
| Anywhere | `L` | Picker of all your comments, `<CR>` jumps to one |
| Anywhere | `S` | Submit review |
| Tree | `<CR>` | Open file |
| Anywhere | `x` | Toggle viewed (file under the cursor in the tree, else the open file) |
| Diff | `]c` / `[c` | Next/prev hunk (native) |
| Diff | `cc`, or `c` in visual mode | Comment on the line or range |
| Diff | `ce` / `cd` | Edit / delete the comment under the cursor (saving an empty edit also deletes) |

## Phases

1. **Diff viewer.** Tree, panes, file navigation, close. Replaces diffview and `:PrDiff`.
2. **Comments.** Add, edit, delete, save to disk, inline display, counts in the tree. Comments outside a hunk are rejected when written, since GitHub returns a 422 for the whole review otherwise. Hunk ranges come from `git diff -U3` headers.
3. **List and submit.** Snacks picker over the comments. Submit is one `gh api POST repos/{repo}/pulls/{n}/reviews` with `commit_id`, `event`, `body`, and every comment. Warn if the PR head moved since loading. Clear the saved file once it succeeds.
4. **Extras.** Viewed marks (reset when the file changes), the real file on the right when the worktree is at head and the file has no local edits (so LSP works), other people's comments shown read-only. A `mux review` launcher is left for later.

## Comment display

Comments show as a sign on their lines and virtual lines under the last one. Diff mode doesn't count virtual lines when it lines up the panes, so the other pane gets the same number of blank virtual lines at the matching line (found with `vim.text.diff`, the engine `:diffthis` uses).

## Known limits

- Git calls block. They're fast for single files, but fetching a PR can take a few seconds.
- Binary files show a placeholder line instead of a diff.
- Comment text under a line doesn't wrap, so long lines are cut off at the pane edge. The picker preview and `e` show the full text.
- Outdated threads (no current line on GitHub) aren't shown, and neither is whether a thread is resolved.
- On a real file buffer, the review's keys (`cc`, `x`, `e`, `q`, ...) replace the normal ones inside the review tab until it closes. In other tabs the normal keys apply.
