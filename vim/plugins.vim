" ============================================================
" vim-plug bootstrap + plugin manifest.
" Only `Plug` declarations belong here — each plugin's own settings/
" functions/commands live in plugins/<name>.vim, sourced below once
" plug#end() has put them on 'runtimepath' (mirrors nvim's lazy_setup.lua,
" which bootstraps lazy.nvim and then imports lua/plugins/*.lua). Their
" keybindings are centralized in mappings.vim instead of living here.
" ============================================================

" --- vim-plug bootstrap ---
let s:plug_vim = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug_vim))
  silent execute '!curl -fLo ' . s:plug_vim . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" vim-polyglot reads this global on load, so unlike the other plugins it
" can't be deferred to plugins/polyglot.vim — it must be set before plug#end().
let g:polyglot_disabled = ['typescript', 'typescriptreact', 'javascript', 'jsx']

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Syntax for everything else; TS/JSX/JS use Vim's own built-in syntax files instead.
Plug 'sheerun/vim-polyglot'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf'
Plug 'mhinz/vim-startify'
Plug '~/Developer/gitlab-vim-theme'

call plug#end()

" --- per-plugin config, one file per plugin (like nvim/lua/plugins/*.lua) ---
let s:plugin_config_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/plugins'
for s:f in sort(glob(s:plugin_config_dir . '/*.vim', 0, 1))
  execute 'source ' . s:f
endfor
unlet s:f s:plugin_config_dir s:plug_vim
