" --- yazi (yazi.nvim equivalent for plain vim) ---
" Picks via --chooser-file then :edit's the result; uses `:!` instead of :terminal since Vim's terminal emulator breaks yazi's startup handshake.
function! s:YaziChooser() abort
  let l:tmpfile = tempname()
  let l:cmd = '!yazi --chooser-file=' . shellescape(l:tmpfile)
  " Root yazi at the current file instead of Vim's cwd; falls back to cwd for unnamed buffers.
  let l:current_file = expand('%:p')
  if !empty(l:current_file)
    let l:cmd .= ' ' . shellescape(l:current_file)
  endif

  " Blanks t_ti/t_te so Vim stays on the alternate screen, avoiding a flash of plain background before yazi paints.
  let l:save_t_ti = &t_ti
  let l:save_t_te = &t_te
  set t_ti= t_te=
  silent execute l:cmd
  let &t_ti = l:save_t_ti
  let &t_te = l:save_t_te

  redraw!
  if filereadable(l:tmpfile)
    for l:path in readfile(l:tmpfile)
      execute 'edit ' . fnameescape(l:path)
    endfor
    call delete(l:tmpfile)
  endif
endfunction

command! YaziChooser call s:YaziChooser()
