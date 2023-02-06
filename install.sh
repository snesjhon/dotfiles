install_stow() {
  if ! command -v stow &> /dev/null; then
    echo "\n  -- installing stow -- \n"

    sudo apt-get install -y stow
  fi
}

stow_dirs() {
  stow -d ~/dotfiles nvim
}

if [ $SPIN ]; then
  install_stow
  stow_dirs
fi
