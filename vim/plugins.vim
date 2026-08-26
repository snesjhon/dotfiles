let s:plug_vim = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug_vim))
  silent execute '!curl -fLo ' . s:plug_vim . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'puremourning/vimspector', { 'do': 'python3 install_gadget.py --force-enable-node' }
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'easymotion/vim-easymotion'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf'
Plug 'mhinz/vim-startify'
Plug 'liuchengxu/vim-which-key'
Plug 'wellle/context.vim'
Plug '~/Developer/gitlab-vim-theme'

call plug#end()

let s:configs_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/configs'
for s:f in sort(glob(s:configs_dir . '/*.vim', 0, 1))
  execute 'source ' . s:f
endfor
unlet s:f s:configs_dir s:plug_vim
