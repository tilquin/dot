# use gnu replacements for mac utils
path=($(brew --prefix coreutils)/libexec/gnubin $path)
MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"
[ -f /Users/gylls/homebrew/etc/profile.d/autojump.sh ] && . /Users/gylls/homebrew/etc/profile.d/autojump.sh
