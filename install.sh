#!/usr/bin/env zsh

install_language_servers() {
  echo "\n -- installing language servers -- \n"
  npm i -g typescript typescript-language-server
  npm i -g vscode-langservers-extracted
  npm i -g graphql-language-service-cli
}

install_packer(){
    git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim &> /dev/null
}

install_dependencies(){
  nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"
}

if [ $SPIN ]; then
  install_packer
  install_language_servers

  ln -sf /home/spin/dotfiles/nvim /home/spin/.config/nvim
fi



