#!/bin/zsh

if [[ $OSTYPE[0,6] == "darwin" ]]
then
    command -v brew > /dev/null 2>&1 || { /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" }
    brew install coreutils binutils findutils zsh ack nvim fasd trash
    brew install iterm2 flycut --cask

    defaults write -app Flycut loadOnStartup 1
    defaults write -app Flycut "ShortcutRecorder mainHotkey" '{ "keyCode" = 9 ; "modifierFlags" = 1310720; }'
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

for file in Library/dot/etc/* .vim/vimrc
do
    ln -s $file .$(basename $file)
done

mkdir -p .config
ln -s ~/.vim .config/nvim
