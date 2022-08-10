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

install_packer(){
    git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim &> /dev/null
}

if [ $SPIN ]; then
  install_fzf
  install_language_servers

  # link configs into vim
  ln -sf /home/spin/dotfiles/nvim /home/spin/.config/nvim

  install_packer
fi



