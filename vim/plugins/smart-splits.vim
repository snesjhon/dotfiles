" ============================================================
" WINDOWS -- reimplements nvim's smart-splits.nvim tmux hand-off at the edge of the window layout.
" ============================================================
" Global (not s:) so mappings.vim, sourced after this file, can call it.
function! VimOrTmuxMove(direction)
  let l:previous_winnr = winnr()
  execute 'wincmd ' . a:direction
  if winnr() == l:previous_winnr && exists('$TMUX')
    call system('tmux select-pane -' . (a:direction ==# 'h' ? 'L' : 'R'))
  endif
endfunction
