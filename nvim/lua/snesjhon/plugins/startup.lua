return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'projekt0n/github-nvim-theme'

  -- Simple plugins can be specified as strings
  use 'tpope/vim-commentary'

  use { 'kyazdani42/nvim-tree.lua', 
    requires = {
    'kyazdani42/nvim-web-devicons'
  }}

  use {'junegunn/fzf', dir = '~/.fzf', run = './install --all'}
  use 'junegunn/fzf.vim'


end)
