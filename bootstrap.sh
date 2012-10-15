#!/bin/zsh

cd
mkdir -p Library
cd Library
git clone git@github.com:gyllstromk/Configuration-Files.git "Configuration files"
cd
ln -s "Library/Configuration files/etc/zshrc" .zshrc
ln -s "Library/Configuration files/etc/zprofile" .zprofile
ln -s "Library/Configuration files/etc/tmux.conf" .tmux.conf

git clone git@github.com:gyllstromk/vim.git .vim
ln -s .vim/vimrc .vimrc
cd .vim
git submodule init
git submodule update
