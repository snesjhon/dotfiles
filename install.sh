#!/usr/bin/env zsh

if [ $SPIN ]; then
  curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"

  ln -sf /home/spin/dotfiles/nvim /home/spin/.config/nvim
fi
