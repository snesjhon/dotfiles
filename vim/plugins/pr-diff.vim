" ============================================================
" PrDiff -- fugitive-free replacement for :Gvdiffsplit. Toggles the current window between
" a plain edit buffer and a vertical native-vimdiff view against the PR's resolved base
" branch (same git-pr-base.sh resolution gp()/:PrFiles/lazygit's `V` custom command share).
" Fixes :Gvdiffsplit's awkward quit -- `:q` only closes one window at a time, leaving diff
" mode stuck on the survivor. Calling this again closes the reference pane and turns diff
" mode off, back to a single plain window -- meant to pair with lazygit's own file
" list + `e`-to-edit flow as the "now show me the diff, now take me back" step.
"
" Opens the reference pane via NoNeckPainSplit (see plugins/no-neck-pain.vim), same as
" every other split in this config: it drops NoNeckPain's centering pads first so the
" split gets the full window width (an even half/half instead of squeezing into the
" narrower centered column), then automatically re-centers once we're back down to one
" window after closing.
" ============================================================
let s:pr_diff_base_script = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/scripts/git-pr-base.sh'

" Whether a PrDiff reference pane is open in the current tab. Checked by buftype rather
" than a stored window id, so <C-q>/:PrDiff close it correctly no matter which of the two
" panes has focus when it's pressed.
function! s:PrDiffActive() abort
  for w in range(1, winnr('$'))
    if getwinvar(w, '&diff') && getbufvar(winbufnr(w), '&buftype') ==# 'nofile'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:PrDiffOff() abort
  for w in range(1, winnr('$'))
    if getwinvar(w, '&diff') && getbufvar(winbufnr(w), '&buftype') ==# 'nofile'
      execute w . 'close'
      break
    endif
  endfor
  diffoff
  silent! nunmap <buffer> <C-q>
endfunction

function! s:PrDiffOn() abort
  let relpath = expand('%')
  if empty(relpath)
    echoerr 'PrDiff: no file in current buffer'
    return
  endif

  let base_script = exists('$GIT_PR_BASE_SCRIPT') ? $GIT_PR_BASE_SCRIPT : s:pr_diff_base_script
  let base = trim(system(base_script . ' 2>&1'))
  if v:shell_error
    echoerr 'PrDiff: ' . base
    return
  endif

  let ft = &filetype
  let orig_winid = win_getid()
  diffthis
  nnoremap <buffer> <silent> <C-q> :PrDiff<CR>

  call NoNeckPainSplit('leftabove vnew')
  setlocal buftype=nofile bufhidden=wipe noswapfile
  " Left empty (rather than dumping git's stderr into the buffer) when the file doesn't
  " exist in the base ref at all -- a file added by this branch -- so the diff correctly
  " shows the whole current file as new instead of a fake one-line "old version".
  let base_content = systemlist('git show ' . shellescape(base . ':./' . relpath) . ' 2>/dev/null')
  if !v:shell_error
    call setline(1, base_content)
  endif
  let &filetype = ft
  setlocal nomodifiable nomodified
  diffthis
  nnoremap <buffer> <silent> <C-q> :PrDiff<CR>

  call win_gotoid(orig_winid)
endfunction

function! s:PrDiffToggle() abort
  if s:PrDiffActive()
    call s:PrDiffOff()
  else
    call s:PrDiffOn()
  endif
endfunction

" Unconditionally (re)shows the diff for the CURRENT buffer, closing any stale reference
" pane left over from a previously diffed file first -- unlike :PrDiff's toggle, used by
" :PrList (pr-list.vim) so jumping to a new file from the quickfix list always refreshes
" the diff instead of sometimes turning it off.
function! s:PrDiffShow() abort
  if s:PrDiffActive()
    call s:PrDiffOff()
  endif
  call s:PrDiffOn()
endfunction

command! PrDiff call s:PrDiffToggle()
command! PrDiffShow call s:PrDiffShow()
