" ============================================================
" no-neck-pain (native) — centers the window with fixed-width scratch splits on both sides; fully native vimscript equivalent of nvim's no-neck-pain.nvim, same width/enable-on-start/<leader>z toggle.
" ============================================================
let g:no_neck_pain_width = get(g:, 'no_neck_pain_width', 130)
let g:no_neck_pain_min_side_width = get(g:, 'no_neck_pain_min_side_width', 10)

let s:enabled = 0
let s:pad_bufnr = -1
let s:main_winid = -1
let s:left_winid = -1
let s:right_winid = -1
let s:main_fillchars = ''
let s:awaiting_reenable = 0

" one shared scratch buffer, displayed in both side windows
function! s:PadBufnr() abort
  if s:pad_bufnr == -1 || !bufexists(s:pad_bufnr)
    let s:pad_bufnr = bufadd('')
    call setbufvar(s:pad_bufnr, '&buftype', 'nofile')
    call setbufvar(s:pad_bufnr, '&bufhidden', 'hide')
    call setbufvar(s:pad_bufnr, '&swapfile', 0)
    call setbufvar(s:pad_bufnr, '&buflisted', 0)
  endif
  return s:pad_bufnr
endfunction

function! s:DecoratePad() abort
  setlocal nonumber norelativenumber nocursorline nolist
  setlocal winfixwidth
  execute 'setlocal statusline=\ '
  execute 'setlocal fillchars=eob:\ '
endfunction

" Strips 'vert' from fillchars to hide the border; must be reapplied whenever a new buffer resets it.
function! s:HideMainVert() abort
  let new_fillchars = substitute(s:main_fillchars, 'vert:[^,]*,\?', '', '')
  execute 'setlocal fillchars=' . (empty(new_fillchars) ? 'fold:-,eob:~,lastline:@' : new_fillchars)
endfunction

function! s:Enable() abort
  if s:enabled || winnr('$') != 1
    return
  endif
  let side_width = (&columns - g:no_neck_pain_width) / 2
  if side_width < g:no_neck_pain_min_side_width
    return
  endif

  let s:main_winid = win_getid()
  let padbuf = s:PadBufnr()

  leftabove vertical split
  execute 'buffer ' . padbuf
  execute 'vertical resize ' . side_width
  call s:DecoratePad()
  let s:left_winid = win_getid()

  call win_gotoid(s:main_winid)
  rightbelow vertical split
  execute 'buffer ' . padbuf
  execute 'vertical resize ' . side_width
  call s:DecoratePad()
  let s:right_winid = win_getid()

  call win_gotoid(s:main_winid)
  let s:main_fillchars = &l:fillchars
  " drop 'vert' so the border renders blank, matching the pad's border on the other side
  call s:HideMainVert()
  setlocal winfixwidth
  let s:enabled = 1
endfunction

function! s:Disable() abort
  if !s:enabled
    return
  endif
  " flip before navigating so SkipPad's guard doesn't bounce focus back before `quit` runs
  let s:enabled = 0
  for winid in [s:left_winid, s:right_winid]
    if win_id2win(winid) != 0
      call win_gotoid(winid)
      quit
    endif
  endfor
  if win_id2win(s:main_winid) != 0
    call win_gotoid(s:main_winid)
    setlocal nowinfixwidth
    execute 'setlocal fillchars=' . s:main_fillchars
  endif
endfunction

function! s:Toggle() abort
  if s:enabled
    call s:Disable()
  else
    call s:Enable()
  endif
endfunction

" Opens a real full-width split by dropping the pads first, restoring them once back to one window.
function! NoNeckPainSplit(cmd) abort
  let was_enabled = s:enabled
  if was_enabled
    call s:Disable()
  endif
  execute a:cmd
  if was_enabled
    if winnr('$') > 1
      let s:awaiting_reenable = 1
    else
      " nothing opened -- undo the disable immediately instead of waiting
      call s:Enable()
    endif
  endif
endfunction

function! s:CheckPendingReenable() abort
  if s:awaiting_reenable && !s:enabled && winnr('$') == 1
    let s:awaiting_reenable = 0
    call s:Enable()
  endif
endfunction

" if focus somehow lands in a pad (e.g. <C-w>w cycling), bounce back out
function! s:SkipPad() abort
  if !s:enabled || bufnr('%') != s:pad_bufnr
    return
  endif
  if win_getid() == s:left_winid
    wincmd l
  elseif win_getid() == s:right_winid
    wincmd h
  endif
endfunction

" Tears down orphaned pads if the main window closes; `quit` avoids E444 on the last remaining pad.
function! s:CheckMainClosed() abort
  if s:enabled && win_id2win(s:main_winid) == 0
    let s:enabled = 0
    for winid in [s:left_winid, s:right_winid]
      if win_id2win(winid) != 0
        call win_gotoid(winid)
        quit
      endif
    endfor
  endif
endfunction

command! NoNeckPain call s:Toggle()

augroup no_neck_pain
  autocmd!
  autocmd VimEnter * call s:Enable()
  autocmd VimResized * if s:enabled | call s:Disable() | call s:Enable() | endif
  autocmd WinEnter * call s:SkipPad()
  " re-hide 'vert' whenever the main window loads a different buffer
  autocmd BufWinEnter * if s:enabled && win_getid() == s:main_winid | call s:HideMainVert() | endif
  " deferred: closing windows from inside a WinClosed handler is unsupported
  autocmd WinClosed * call timer_start(0, {-> s:CheckMainClosed()})
  autocmd WinClosed * call timer_start(0, {-> s:CheckPendingReenable()})
augroup END

command! NNPDebug echo 'enabled=' . s:enabled . ' awaiting=' . s:awaiting_reenable . ' winnr=' . winnr('$') . ' main=' . s:main_winid . ' left=' . s:left_winid . ' right=' . s:right_winid
