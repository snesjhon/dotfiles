#!/usr/bin/env zsh

install_packer(){
    git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
}

install_dependencies(){
  nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"
}

if [ $SPIN ]; then
  install_packer

  ln -sf /home/spin/dotfiles/nvim /home/spin/.config/nvim
fi
