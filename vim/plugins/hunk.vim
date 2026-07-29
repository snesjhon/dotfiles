" --- hunk (terminal diff viewer; PR review) ---
" Shells out via `:!`, same pattern as yazi.vim -- unlike the old lumen integration, hunk
" doesn't call back into an editor, so no EDITOR-shim/resume dance is needed here: blank
" t_ti/t_te so Vim stays on the alternate screen, run silently, restore, redraw.
"
" Diffs against the PR's resolved base (same git-pr-base.sh resolution gp()/:PrDiff share)
" rather than bare working-tree changes, so C-S-h reviews "what this branch changed" instead
" of just the last commit or uncommitted edits.
let s:hunk_base_script = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/scripts/git-pr-base.sh'

function! s:HunkShow() abort
  let base_script = exists('$GIT_PR_BASE_SCRIPT') ? $GIT_PR_BASE_SCRIPT : s:hunk_base_script
  let base = trim(system(base_script . ' 2>&1'))
  if v:shell_error
    echoerr 'HunkShow: ' . base
    return
  endif

  let l:save_t_ti = &t_ti
  let l:save_t_te = &t_te
  set t_ti= t_te=
  silent execute '!hunk diff ' . shellescape(base . '...HEAD')
  let &t_ti = l:save_t_ti
  let &t_te = l:save_t_te
  redraw!
endfunction

command! HunkShow call s:HunkShow()
