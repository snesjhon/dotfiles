" ============================================================
" WINDOWS -- reimplements nvim's smart-splits.nvim tmux hand-off at the edge of the window layout.
" ============================================================
" Global (not s:) so mappings.vim, sourced after this file, can call it.
let s:tmux_pane_flags = {'h': 'L', 'l': 'R', 'j': 'D', 'k': 'U'}

function! VimOrTmuxMove(direction)
  let l:previous_winnr = winnr()
  execute 'wincmd ' . a:direction
  if winnr() == l:previous_winnr && exists('$TMUX')
    call system('tmux select-pane -' . s:tmux_pane_flags[a:direction])
  endif
endfunction
