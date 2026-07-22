" ============================================================
" fugitive -- settings/functions for tpope/vim-fugitive (+ rhubarb).
" Keybindings live in mappings.vim; see also the '+git' tree in
" plugins/which-key.vim.
" ============================================================

" :Gclog opens the file-history quickfix list but hands focus back to the
" original window (it wincmd p's after botright-opening it) so the diff of
" the newest commit loads where you were, not in the log itself -- :copen
" jumps focus into the list so you can walk it right away.
function! FugitiveFileHistory() abort
  execute '0Gclog'
  copen
endfunction
