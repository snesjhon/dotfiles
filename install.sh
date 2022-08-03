#!/usr/bin/env zsh

install_dependencies(){
echo "\n -- installing plug --"
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

if [$SPIN]; then
  install_dependencies
fi
