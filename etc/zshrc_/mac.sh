# use gnu replacements for mac utils
path=($(brew --prefix coreutils)/libexec/gnubin $path)
MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"
eval "$(zoxide init zsh --cmd j)"
