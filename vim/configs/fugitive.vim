" ============================================================
" fugitive -- settings/functions for tpope/vim-fugitive (+ rhubarb). Keybindings live in mappings.vim; see also the '+git' tree in configs/which-key.vim.
" Machine-specific rhubarb config (e.g. g:github_enterprise_urls) lives in configs/options.local.vim.
" ============================================================

" :Gclog opens the file-history quickfix list but returns focus to the original window (unlike :copen) so the diff loads where you were, not in the log itself.
function! FugitiveFileHistory() abort
  execute '0Gclog'
  copen
endfunction
