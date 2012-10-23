#!/bin/zsh

cd
mkdir -p Library

git clone https://github.com/gyllstromk/dot.git "Library/dot"
git clone --recursive https://github.com/gyllstromk/vim .vim

for file in Library/dot/*
do
    ln -s $file .$(basename $file)
done

ln -s .vim/vimrc .vimrc
cd .vim
