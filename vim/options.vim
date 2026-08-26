" ============================================================
" Vanilla Vim options -- vim.opt.lua equivalent. No plugin declarations, no keybindings.
" ============================================================
set nocompatible
set background=light
syntax enable
filetype plugin indent on

set nonumber
set norelativenumber
set cursorline
set expandtab shiftwidth=2 tabstop=2 softtabstop=2
set ignorecase smartcase incsearch hlsearch
set clipboard=unnamed
set hidden
set termguicolors
set signcolumn=yes
set nowrap
set mouse=a

" coc.nvim's undercurl diagnostics need these termcap strings; auto-detection doesn't resolve through tmux.
let &t_Cs = "\<Esc>[4:3m"
let &t_Ce = "\<Esc>[4:0m"
let &t_8u = "\<Esc>[58:2:%lu:%lu:%lum"
set laststatus=0
set showmode
set scrolloff=999

" Shrinks Vim's Esc key-disambiguation wait so it doesn't flash visibly in tmux.
set ttimeoutlen=10
set shortmess+=F
set foldmethod=syntax
set foldlevelstart=99

" Mimics Neovim's per-mode cursor shapes; resets to block on exit.
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"
autocmd VimLeave * silent !echo -ne "\e[2 q"

" Forces the NFA regex engine -- the default 'auto' selection caused 'redrawtime exceeded' hangs in real TSX files.
set regexpengine=2
