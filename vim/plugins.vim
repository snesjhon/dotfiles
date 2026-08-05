" ============================================================
" vim-plug bootstrap + plugin manifest. Only `Plug` declarations belong here — settings/functions live in plugins/<name>.vim, sourced after plug#end() (mirrors nvim's lazy_setup.lua). Keybindings live in mappings.vim.
" ============================================================

" --- vim-plug bootstrap ---
let s:plug_vim = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug_vim))
  silent execute '!curl -fLo ' . s:plug_vim . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" vim-polyglot reads this global on load, so unlike other plugins it can't be deferred to plugins/polyglot.vim — it must be set before plug#end().
let g:polyglot_disabled = ['typescript', 'typescriptreact', 'javascript', 'jsx']

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" DAP client (breakpoints/step/attach) for Java and TypeScript; needs Vim built
" with +python3, hence Homebrew's vim rather than the macOS system one.
" 'do' auto-installs the vscode-js-debug gadget (Node/TS adapter) on install/update;
" Java has no gadget here since it reuses coc-java's own jdt.ls instead (see plugins/vimspector.vim).
Plug 'puremourning/vimspector', { 'do': 'python3 install_gadget.py --force-enable-node' }

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
Plug 'liuchengxu/vim-which-key'
Plug '~/Developer/gitlab-vim-theme'

call plug#end()

" --- per-plugin config, one file per plugin (like nvim/lua/plugins/*.lua) ---
let s:plugin_config_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/plugins'
for s:f in sort(glob(s:plugin_config_dir . '/*.vim', 0, 1))
  execute 'source ' . s:f
endfor
unlet s:f s:plugin_config_dir s:plug_vim
