" ============================================================
" fugitive -- settings/functions for tpope/vim-fugitive (+ rhubarb). Keybindings live in mappings.vim; see also the '+git' tree in plugins/which-key.vim.
" ============================================================

" Machine-specific rhubarb config (e.g. g:github_enterprise_urls) that shouldn't live in the public dotfiles. Gitignored.
let s:fugitive_local_config = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/fugitive.local.vim'
if filereadable(s:fugitive_local_config)
  execute 'source ' . s:fugitive_local_config
endif
unlet s:fugitive_local_config

" :Gclog opens the file-history quickfix list but returns focus to the original window (unlike :copen) so the diff loads where you were, not in the log itself.
function! FugitiveFileHistory() abort
  execute '0Gclog'
  copen
endfunction
