#!/bin/zsh

cd
mkdir -p Library
cd Library
git clone git@github.com:gyllstromk/dot.git "dot"
cd
ln -s "Library/dot/etc/zshrc" .zshrc
ln -s "Library/dot/etc/zprofile" .zprofile
ln -s "Library/dot/etc/tmux.conf" .tmux.conf

git clone git@github.com:gyllstromk/vim.git .vim
ln -s .vim/vimrc .vimrc
cd .vim
git submodule init
git submodule update
