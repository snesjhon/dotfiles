" ============================================================
" All custom keybindings, centralized here regardless of whether they're
" built-in Vim features or belong to a plugin. Settings/functions/commands
" all live in plugins/*.vim instead -- see plugins.vim. This file only
" binds keys; it defines no functions of its own.
" ============================================================

" --- built-in Vim features (no plugin) ---

" --- window splits ---
nnoremap <silent> <Bar> :call NoNeckPainSplit('vsplit')<CR>

" --- smart-splits (native reimplementation, see plugins/smart-splits.vim) ---
nnoremap <silent> <C-h> :call VimOrTmuxMove('h')<CR>
nnoremap <silent> <C-l> :call VimOrTmuxMove('l')<CR>

nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprevious<CR>

nnoremap <C-S-w> :bp<bar>bd #<CR>
nnoremap <C-S-q> :q<CR>
nnoremap <F10> :w<CR>

nnoremap <leader>/ :Commentary<CR>


" --- UI toggles ---
nnoremap <leader>uw :set wrap!<CR>

" --- terminal (no floating window support in plain vim) ---
" nnoremap <F4> :botright term ++rows=15<CR>
" tnoremap <F4> <C-\><C-n>:q<CR>
nnoremap <leader>tt :botright term ++rows=15<CR>

nnoremap vv V


" ============================================================
" Plugin mappings. Each plugin's own settings/functions/commands still
" live in plugins/<name>.vim (sourced before this file, see plugins.vim) --
" this file only binds keys to what they expose.
" ============================================================

" --- easymotion (flash.nvim equivalent) ---
map s <Plug>(easymotion-sn)

" --- coc.nvim: standard recommended bindings ---
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CocCheckBackSpace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"

" Manual completion trigger; <Nul> is mapped too since terminals send Ctrl-Space as a NUL byte.
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <Nul> coc#refresh()

" Navigate the pum with <C-j>/<C-k>, falling back to their default
" insert-mode behavior (linefeed / digraph entry) when it's not visible.
inoremap <expr><c-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <expr><c-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> grr <Plug>(coc-references)
nmap <silent> gh :call CocActionAsync('doHover')<CR>
nmap <silent> g<Bar> :call NoNeckPainSplit("call CocAction('jumpDefinition', 'vsplit')")<CR>

nmap <leader>rn <Plug>(coc-rename)
nmap <silent> gf <Plug>(coc-format)

nmap [g <Plug>(coc-diagnostic-prev)
nmap ]g <Plug>(coc-diagnostic-next)

" --- fugitive (+ rhubarb for :GBrowse) ---
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit main<CR>
nnoremap <leader>gl :Git log --oneline<CR>
nnoremap <leader>gi :GBrowse!<CR>

" PR review: turns the diff into a navigable pager buffer, fugitive's equivalent of nvim's diffview.nvim.
nnoremap <leader>gj :Git diff origin/main...HEAD<CR>
" Per-file commit history via :Gclog, fugitive's equivalent of :DiffviewFileHistory %.
nnoremap <leader>gh :0Gclog<CR>

" --- fzf ---
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fw :Rg<CR>

" --- coc lists, via fzf (see plugins/coc-fzf.vim) ---
nnoremap <leader>lo :CocFzfList outline<CR>
nnoremap <leader>ld :CocFzfList diagnostics<CR>
nnoremap <leader>lc :CocFzfList commands<CR>

" --- no-neck-pain ---
nnoremap <leader>z :NoNeckPain<CR>

" --- vim-startify ---
nnoremap <leader>h :Startify<CR>

" --- gitlab-vim-theme ---
nnoremap <leader>ut :ToggleTheme<CR>

" --- yazi ---
nnoremap <silent> <F6> :YaziChooser<CR>
