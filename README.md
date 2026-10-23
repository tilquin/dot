Bootstrap my dot files on Mac, Linux, and EC2

    /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/tilquin/dot/master/bootstrap.sh)"

`bootstrap.sh` automatically runs every executable `bootstrap.d/*.sh` file.
Each script can also be run independently, for example:

    ~/Library/dot/bootstrap.d/maccy.sh
