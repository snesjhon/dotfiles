" --- coc-fzf: pipe coc.nvim's own lists through fzf instead of :CocList's split-buffer UI ---
" Matches coc-fzf's styling to fzf.vim's tmux-popup look instead of its own defaults.
let g:coc_fzf_preview = 'right:50%'

" Same modal nav as :Files/:Rg (plugins/fzf.vim's FzfModalNavBinds), deferred to VimEnter for load order.
" --wrap mirrors :Rg's fix in plugins/fzf.vim -- coc-fzf's lists (grr/gd/gy/gi jumps, outline,
" diagnostics, etc.) format entries as the same long "path:line:col:text" line, so without it
" long paths truncate instead of showing where the match actually is.
autocmd VimEnter * let g:coc_fzf_opts = ['--wrap'] + FzfModalNavBinds()
