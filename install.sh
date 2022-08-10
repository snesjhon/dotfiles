#!/usr/bin/env zsh

install_fzf() {
  if ! command -v fzf &> /dev/null; then
    echo "\n  -- installing fzf -- \n"

    sudo apt-get install -y fzf
  fi
}

install_language_servers() {
  echo "\n -- installing language servers -- \n"
  npm i -g typescript typescript-language-server
  npm i -g vscode-langservers-extracted
  npm i -g graphql-language-service-cli
}

install_stow() {
  if ! command -v stow &> /dev/null; then
    echo "\n  -- installing stow -- \n"

    sudo apt-get install -y stow
  fi
}

install_packer(){
    git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim &> /dev/null
}

install_dependencies(){
  install_fzf
  install_packer
  install_stow
  install_language_servers
}

stow_dirs() {
  stow -d ~/dotfiles nvim
}

if [ $SPIN ]; then
  install_dependencies
  stow_dirs
  install_packer
fi



