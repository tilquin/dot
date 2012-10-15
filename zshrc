#
# /etc/zshrc is sourced in interactive shells.  It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#

# greeting for me

#/usr/games/fortune -s
#

# oh-my-zsh

ZSH=$HOME/.oh-my-zsh
ZSH_THEME="afowler"
plugins=(osx npm tmux)
source $ZSH/oh-my-zsh.sh
alias ts=trash
CASE_SENSITIVE="true"

export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

# python
alias dev="if [ ! -e env/dev ]; then; mkdir -p env; virtualenv --distribute env/dev; fi; source ./env/dev/bin/activate"
export PYTHONPATH=.
export PYTHONSTARTUP=~/.pystartup

# node
export NODE_PATH=/usr/local/lib/node_modules
path=(/usr/local/share/npm/bin $path)

binarypath="$HOME/Library/Scripts and binaries"
configpath="$HOME/Library/Configuration files"

# Set up aliases

alias igrep='grep -i'
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
alias rrm=\"/bin/rm\" # no spelling correction on mkdir
alias d="cd .."

# Set prompts
#if [ $SHLVL -gt 1 ]
#then
#	export PROMPT="($SHLVL) %m:%~$ "
#else
#	export PROMPT="%m:%~$ "
#fi

# Some environment variables
#TRASH=("/home/karl/trash")

path=(/usr/local/bin $binarypath /sbin /usr/sbin $path)

#if [ -f `brew --prefix`/etc/autojump ]; then
#    . `brew --prefix`/etc/autojump
#fi

if [[ $OSTYPE[0,6] == "darwin" ]]
then
	export LC_ALL="en_US.utf-8"
	export LANG="en_US.utf-8"
	#macports=(/opt/local/bin /opt/local/sbin)
	path=(/usr/local/Cellar/ruby/1.9.3-p194/bin $path)
	alias gvim=open -a MacVim
	alias top="top -o cpu"
	alias ls='ls -G'
#    export LSCOLORS=ExFxBxDxCxegedabagacad
#    export LSCOLORS=ExFxCxDxHxegedabagacad
else
	alias ls='ls --color=tty'
    export LS_COLORS="di=34;40:ln=35;40:so=32;40:pi=33;40:ex=37;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43":
fi

export TRASH="$HOME/.Trash"

bindkey -v             # vi key bindings
bindkey ' ' magic-space  # also do history expansino on space

alias back='cd $OLDPWD'
alias no='ls'

autoload -U compinit ; compinit

export EDITOR='vim'

# vi style incremental search

bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward  

if [ -f `brew --prefix`/etc/autojump ]; then
  . `brew --prefix`/etc/autojump
fi

[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
