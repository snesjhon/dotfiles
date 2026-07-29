" --- lazygit (lazygit.nvim's floating window equivalent for plain vim) ---
" Shells out with `:!` for a real TTY (same trick as YaziChooser); buffers are re-synced with :checktime after, since lazygit can checkout/discard/stash from under us.
function! s:LazyGit() abort
  let l:save_t_ti = &t_ti
  let l:save_t_te = &t_te
  set t_ti= t_te=
  silent !lazygit
  let &t_ti = l:save_t_ti
  let &t_te = l:save_t_te

  redraw!
  checktime
endfunction

command! LazyGit call s:LazyGit()
