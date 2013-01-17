#!/bin/zsh

cd
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
rm .zshrc

mkdir -p Library

git clone https://github.com/gyllstromk/dot.git "Library/dot"
git clone --recursive https://github.com/gyllstromk/vim .vim

for file in Library/dot/*
do
    ln -s $file .$(basename $file)
done
