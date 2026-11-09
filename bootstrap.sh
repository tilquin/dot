#!/bin/zsh

set -e

DOT_DIR="$HOME/Library/dot"
typeset -i BREW_BUNDLE_FAILED=0
typeset -a BOOTSTRAP_FAILURES=()

is_mac() {
    [[ "$OSTYPE" == darwin* ]]
}

clone_if_missing() {
    local repository=$1
    local destination=$2
    shift 2

    if [[ -d "$destination/.git" || -f "$destination/.git" ]]
    then
        echo "Already cloned: $destination"
    elif [[ -e "$destination" ]]
    then
        echo >&2 "Cannot clone $repository: $destination already exists"
        return 1
    else
        git clone "$@" "$repository" "$destination"
    fi
}

link_if_needed() {
    local source=$1
    local destination=$2

    if [[ -L "$destination" && "${destination:A}" == "${source:A}" ]]
    then
        return
    elif [[ -L "$destination" ]]
    then
        ln -sfn "$source" "$destination"
    elif [[ -e "$destination" ]]
    then
        echo >&2 "Skipping $destination: it exists and is not a symlink"
    else
        ln -s "$source" "$destination"
    fi
}

brew_install_bundle() {
    local brewfile="$DOT_DIR/Brewfile"

    if [[ ! -f "$brewfile" ]]
    then
        echo >&2 "Homebrew manifest is missing: $brewfile"
        BREW_BUNDLE_FAILED=1
    elif brew bundle check --file="$brewfile" --no-upgrade
    then
        echo "Homebrew bundle is already installed"
    elif ! brew bundle install --file="$brewfile" --no-upgrade
    then
        BREW_BUNDLE_FAILED=1
    fi

    return 0
}

run_bootstrap_scripts() {
    local script
    local -a scripts

    scripts=("$DOT_DIR"/bootstrap.d/*.sh(N))
    for script in "${scripts[@]}"
    do
        if [[ ! -f "$script" || ! -r "$script" ]]
        then
            echo >&2 "Bootstrap script is not a readable file: $script"
            BOOTSTRAP_FAILURES+=("${script:t} (not readable)")
            continue
        fi

        echo "Running ${script:t}"
        if ! /bin/zsh -f "$script"
        then
            BOOTSTRAP_FAILURES+=("${script:t}")
        fi
    done

    return 0
}

if is_mac
then
    if ! command -v brew > /dev/null 2>&1
    then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ -x /opt/homebrew/bin/brew ]]
        then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]
        then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "Homebrew is already installed"
    fi
fi

command -v git > /dev/null 2>&1 || { echo >&2 "git must be installed"; exit 1; }

if [[ "$OSTYPE" == linux* && "$SHELL" != /bin/zsh ]]
then
    sudo chsh -s /bin/zsh "$USER"
fi

mkdir -p "$HOME/Library" "$HOME/.Trash" "$HOME/.config"

clone_if_missing https://github.com/tilquin/dot.git "$DOT_DIR" --recursive
clone_if_missing https://github.com/tilquin/gitastic.git "$DOT_DIR/git"
clone_if_missing https://github.com/gyllstromk/vim.git "$HOME/.vim"
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if is_mac
then
    brew_install_bundle
fi

run_bootstrap_scripts

for file in "$DOT_DIR"/etc/*
do
    link_if_needed "$file" "$HOME/.$(basename "$file")"
done

link_if_needed "$HOME/.vim" "$HOME/.config/nvim"

if (( BREW_BUNDLE_FAILED || ${#BOOTSTRAP_FAILURES[@]} > 0 ))
then
    if (( BREW_BUNDLE_FAILED ))
    then
        echo >&2
        echo >&2 "Homebrew bundle installation failed. Retry with:"
        printf >&2 '  brew bundle install --file="%s/Brewfile" --no-upgrade\n' "$DOT_DIR"
    fi

    if (( ${#BOOTSTRAP_FAILURES[@]} > 0 ))
    then
        echo >&2
        echo >&2 "These bootstrap scripts failed:"
        printf >&2 '  - %s\n' "${BOOTSTRAP_FAILURES[@]}"
    fi

    exit 1
fi

echo "Bootstrap completed successfully"
