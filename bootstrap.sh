#!/bin/zsh

cd
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

mkdir -p Library

git clone git@github.com:gyllstromk/dot.git "Library/dot"
git clone --recursive git@github.com:gyllstromk/vim.git .vim

ln -s "Library/dot/etc/zshrc" .zshrc
ln -s "Library/dot/etc/zprofile" .zprofile
ln -s "Library/dot/etc/tmux.conf" .tmux.conf
ln -s .vim/vimrc .vimrc