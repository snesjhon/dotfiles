" ============================================================
" PrList -- plain-vim PR review sidebar: a quickfix list of files changed vs the PR's
" resolved base branch (same git-pr-base.sh resolution gp()/:PrFiles/:PrDiff share), opened
" as a horizontal split at the bottom. <CR> on an entry jumps to that file in the window
" above and shows its diff (:PrDiffShow, see pr-diff.vim) -- no fzf popup, no fugitive.
"
" Reuses vim's own quickfix window rather than inventing a picker: nothing else in this
" config populates the native quickfix list, so repurposing its <CR> here doesn't collide
" with any other usage.
" ============================================================
let s:pr_list_base_script = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/scripts/git-pr-base.sh'

function! s:PrList() abort
  let base_script = exists('$GIT_PR_BASE_SCRIPT') ? $GIT_PR_BASE_SCRIPT : s:pr_list_base_script
  let base = trim(system(base_script . ' 2>&1'))
  if v:shell_error
    echoerr 'PrList: ' . base
    return
  endif

  let files = systemlist('git diff --name-only ' . shellescape(base . '...HEAD'))
  if v:shell_error
    echoerr 'PrList: ' . join(files, ' ')
    return
  endif
  if empty(files)
    echom 'PrList: no changes vs ' . base
    return
  endif

  let qflist = map(copy(files), {_, f -> {'filename': f, 'lnum': 1, 'text': f}})
  call setqflist([], ' ', {'title': 'PR vs ' . base, 'items': qflist})

  call NoNeckPainSplit('botright copen')
  execute 'resize ' . min([10, len(files) + 1])
  nnoremap <buffer> <silent> <CR> <CR>:PrDiffShow<CR>
endfunction

command! PrList call s:PrList()
