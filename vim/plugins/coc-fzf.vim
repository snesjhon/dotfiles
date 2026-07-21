" --- coc-fzf: pipe coc.nvim's own lists through fzf instead of :CocList's split-buffer UI ---
" Matches coc-fzf's styling to fzf.vim's tmux-popup look instead of its own defaults.
let g:coc_fzf_preview = 'right:50%'

" Same modal nav as :Files/:Rg (plugins/fzf.vim's FzfModalNavBinds), deferred to VimEnter for load order.
autocmd VimEnter * let g:coc_fzf_opts = FzfModalNavBinds()
