# node
export NODE_PATH=/usr/local/lib/node_modules
path=(/usr/local/share/npm/bin $path)
alias jshint=./node_modules/.bin/jshint
alias mocha=./node_modules/.bin/mocha
alias grunt=./node_modules/.bin/grunt
[ -r ~/.nvm/nvm.sh ] && source ~/.nvm/nvm.sh && nvm use 0.10 > /dev/null

alias mocha=./node_modules/.bin/mocha
alias jshint=./node_modules/.bin/jshint
