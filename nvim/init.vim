call plug#begin()

  " Theme
  Plug 'projekt0n/github-nvim-theme'

  " Sidebar
  Plug 'scrooloose/nerdtree'
  Plug 'ryanoasis/vim-devicons'

  " Search
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

call plug#end()

let mapleader=" "
noremap <SPACE> <Nop>

set number
set mouse=a
set noerrorbells
set belloff=all
set showcmd
set showmode
set encoding=utf-8
set clipboard=unnamedplus
set tabstop=4
set shiftwidth=4
set expandtab
set nu
set nowrap

syntax on
colorscheme github_light_default


" Remaps
nmap <leader>h 0
nmap <leader>l $
