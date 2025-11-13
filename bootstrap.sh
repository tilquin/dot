#!/bin/zsh

if [[ $OSTYPE[0,6] == "darwin" ]]
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    xargs /opt/homebrew/bin/brew install < settings/brew.freeze.txt
    xargs /opt/homebrew/bin/brew install --cask < settings/brew-cask.freeze.txt
fi

command -v git > /dev/null 2>&1 || { echo >&2 "git must be installed"; exit 1; }

cd
rm .zshrc

if [[ $OSTYPE[0,5] == "linux" ]]
then
    sudo chsh -s /bin/zsh $USER
fi

mkdir -p Library
mkdir -p ~/.Trash

git clone --recursive https://github.com/tilquin/dot.git "Library/dot"
git clone https://github.com/tilquin/gitastic.git "Library/dot/git"
git clone https://github.com/gyllstromk/vim.git .vim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

for file in Library/dot/etc/*
do
    ln -s $file .$(basename $file)
done

mkdir -p .config
ln -s ~/.vim .config/nvim
