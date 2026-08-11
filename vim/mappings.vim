" ============================================================
" All custom keybindings, centralized here regardless of built-in/plugin origin; settings/functions live in plugins/*.vim instead. This file only binds keys.
" ============================================================

" --- window splits ---
nnoremap <silent> - :call NoNeckPainSplit('vsplit')<CR>

" --- smart-splits (native reimplementation, see plugins/smart-splits.vim) ---
nnoremap <silent> <C-h> :call VimOrTmuxMove('h')<CR>
nnoremap <silent> <C-l> :call VimOrTmuxMove('l')<CR>
nnoremap <silent> <C-j> :call VimOrTmuxMove('j')<CR>
nnoremap <silent> <C-k> :call VimOrTmuxMove('k')<CR>

" coc's own recommended mapping for scrolling a float (e.g. gh's hover) in place.
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

nnoremap . :bnext<CR>
nnoremap , :bprevious<CR>

nnoremap <C-S-w> :bp<bar>bd #<CR>
nnoremap <C-S-q> :q<CR>
nnoremap <F10> :w<CR>

nnoremap <leader>/ :Commentary<CR>

" --- UI toggles ---
nnoremap <leader>uw :set wrap!<CR>

" --- terminal (no floating window support in plain vim) ---
nnoremap <leader>tt :call NoNeckPainSplit('vertical botright term')<CR>

" Reuse the same smart-splits move to jump out of a terminal window, leaving terminal-job mode first (<C-\><C-n>) so C-h/j/k/l don't go straight to the shell.
tnoremap <silent> <C-h> <C-\><C-n>:call VimOrTmuxMove('h')<CR>
tnoremap <silent> <C-l> <C-\><C-n>:call VimOrTmuxMove('l')<CR>
tnoremap <silent> <C-j> <C-\><C-n>:call VimOrTmuxMove('j')<CR>
tnoremap <silent> <C-k> <C-\><C-n>:call VimOrTmuxMove('k')<CR>

" I just like doing vv instead of shift
nnoremap vv V

nnoremap L g_
nnoremap H 0

" ============================================================
" Plugin mappings -- each plugin's own settings/functions/commands still live in plugins/<name>.vim; this file only binds keys to what they expose.
" ============================================================

" --- vim-which-key (see plugins/which-key.vim for the menu tree) ---
nnoremap <silent> <leader> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent WhichKeyVisual '<Space>'<CR>

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

" Navigate the pum with <C-j>/<C-k>, falling back to default insert-mode behavior (linefeed/digraph entry) when it's not visible.
inoremap <expr><c-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <expr><c-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> grr <Plug>(coc-references)
nmap <silent> gh :call CocActionAsync('doHover')<CR>
nmap <silent> gl :call CocShowAndFocusHover()<CR>
nmap <silent> g- :call NoNeckPainSplit("call CocAction('jumpDefinition', 'botright vsplit')")<CR>

nmap <leader>rn <Plug>(coc-rename)
nmap <silent> gf <Plug>(coc-format)

nmap [g <Plug>(coc-diagnostic-prev)
nmap ]g <Plug>(coc-diagnostic-next)

" --- GITHUB ---
nnoremap <leader>gs :Git<CR>
" Native vertical vimdiff against the PR's resolved base branch, toggled by the same key (see plugins/pr-diff.vim).
" nnoremap <leader>gd :PrDiff<CR>
nnoremap <leader>gl :Git log --oneline<CR>
nnoremap <leader>gi :GBrowse<CR>

" Per-file commit history via :Gclog, fugitive's equivalent of :DiffviewFileHistory %.
nnoremap <leader>gh :call FugitiveFileHistory()<CR>

" --- lazygit (see plugins/lazygit.vim) ---
nnoremap <leader>gg :LazyGit<CR>

" --- fzf ---
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fw :Rg<CR>


" --- coc lists, via fzf (see plugins/coc-fzf.vim) ---
nnoremap <leader>lo :CocFzfList outline<CR>
nnoremap <leader>ld :CocFzfList diagnostics<CR>
nnoremap <leader>lc :CocFzfList commands<CR>

" Prompt for a code action at the cursor (imports, quick fixes, refactors) -- coc's equivalent of nvim's code-action picker.
nnoremap <silent> <leader>la :call CocActionAsync('codeAction', 'cursor')<CR>

" --- vimspector (see plugins/vimspector.vim for the Java/TS adapter wiring) ---
nmap <silent> <leader>dd <Plug>(debug-start)
nmap <silent> <leader>db <Plug>VimspectorToggleBreakpoint
nmap <silent> <leader>do <Plug>VimspectorStepOver
nmap <silent> <leader>di <Plug>VimspectorStepInto
nmap <silent> <leader>du <Plug>VimspectorStepOut
nmap <silent> <leader>ds <Plug>VimspectorStop
nmap <silent> <leader>dr <Plug>VimspectorRestart

" --- no-neck-pain ---
nnoremap <leader>z :NoNeckPain<CR>

" --- vim-startify ---
nnoremap <leader>h :Startify<CR>

" --- gitlab-vim-theme ---
nnoremap <leader>ut :ToggleTheme<CR>
