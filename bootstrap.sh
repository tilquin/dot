#!/bin/zsh

if [[ $OSTYPE[0,6] == "darwin" ]]
then
	command -v brew > /dev/null 2>&1 || { echo >&2 "brew must be installed"; exit 1; }
	brew install reattach-to-user-namespace
fi

command -v git > /dev/null 2>&1 || { echo >&2 "git must be installed"; exit 1; }

cd
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
rm .zshrc

mkdir -p Library
mkdir -p ~/.Trash

git clone https://github.com/gyllstromk/dot.git "Library/dot"
git clone --recursive https://github.com/gyllstromk/vim .vim

for file in Library/dot/etc/*
do
    ln -s $file .$(basename $file)
done

ln -s .vim/vimrc .vimrc
