#!/bin/zsh

cd
mkdir -p Library
cd Library
git clone git@github.com:gyllstromk/Configuration-Files.git "Configuration files"
cd
ln -s "Library/Configuration files/zshrc" .zshrc
ln -s "Library/Configuration files/zprofile" .zprofile
ln -s "Library/Configuration files/tmux.conf" .tmux.conf

git clone git@github.com:gyllstromk/vim.git .vim
ln -s .vim/vimrc .vimrc
