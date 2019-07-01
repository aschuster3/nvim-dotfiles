#!/bin/bash

if ! foobar_loc="$(type -p brew)" || [[ -z $foobar_loc ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Brew is installed"
fi

if ! foobar_loc="$(type -p nvim)" || [[ -z $foobar_loc ]]; then
  brew install neovim
else
  echo "Neovim is installed"
fi

echo "Setting symlinks"
ln -s ~/.config/nvim/.vimrc ~/.vimrc
ln -s ~/.config/nvim/.vimrc ~/.config/nvim/init.vim

echo "Success!"
echo
echo "Be sure to make an alias for vim to nvim"
