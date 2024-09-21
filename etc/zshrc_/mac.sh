export PATH=$PATH:~/Library/Python/3.9/bin/

[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# use gnu replacements for mac utils
path=(`brew --prefix coreutils`/libexec/gnubin $path)
MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"
