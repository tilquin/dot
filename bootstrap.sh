#!/bin/zsh

if [[ $OSTYPE[0,6] == "darwin" ]]
then
	brewpath=$(which brew)
	if [[ $brewpath == '' ]]
	then
		echo 'brew must be installed'
		exit 1
	fi

	zshpath=$(which zsh)
	if [[ $zshpath == '' ]]
	then
		echo 'zsh must be installed'
		exit 1
	fi

	brew install reattach-to-user-namespace
fi

gitpath=$(which git)
if [[ $gitpath == '' ]]
then
	echo 'Git not installed'
	exit 1
fi

cd
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
rm .zshrc

mkdir -p Library

git clone https://github.com/gyllstromk/dot.git "Library/dot"
git clone --recursive https://github.com/gyllstromk/vim .vim

for file in Library/dot/etc/*
do
    ln -s $file .$(basename $file)
done

ln -s .vim/vimrc .vimrc
