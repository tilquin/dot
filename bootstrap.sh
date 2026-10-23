#!/bin/zsh

set -e

DOT_DIR="$HOME/Library/dot"
typeset -a BREW_FAILURES=()
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

brew_install_from_file() {
    local kind=$1
    local package_file=$2
    local package
    local -a install_command

    while IFS= read -r package || [[ -n "$package" ]]
    do
        [[ -z "$package" || "$package" == \#* ]] && continue

        if brew list "--$kind" "$package" > /dev/null 2>&1
        then
            echo "Already installed: $package"
        else
            if [[ "$kind" == cask ]]
            then
                install_command=(brew install -y --cask "$package")
            else
                install_command=(brew install -y "$package")
            fi

            echo "Installing $kind: $package"
            if ! "${install_command[@]}"
            then
                echo >&2 "Failed to install $kind: $package"
                BREW_FAILURES+=("$kind: $package")
            fi
        fi
    done < "$package_file"

    return 0
}

run_bootstrap_scripts() {
    local script
    local -a scripts

    scripts=("$DOT_DIR"/bootstrap.d/*.sh(N))
    for script in "${scripts[@]}"
    do
        if [[ ! -x "$script" ]]
        then
            echo >&2 "Bootstrap script is not executable: $script"
            BOOTSTRAP_FAILURES+=("${script:t} (not executable)")
            continue
        fi

        echo "Running ${script:t}"
        if ! "$script"
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
    brew_install_from_file formula "$DOT_DIR/settings/brew.freeze.txt"
    brew_install_from_file cask "$DOT_DIR/settings/brew-cask.freeze.txt"
fi

run_bootstrap_scripts

for file in "$DOT_DIR"/etc/*
do
    link_if_needed "$file" "$HOME/.$(basename "$file")"
done

link_if_needed "$HOME/.vim" "$HOME/.config/nvim"

if (( ${#BREW_FAILURES[@]} > 0 || ${#BOOTSTRAP_FAILURES[@]} > 0 ))
then
    if (( ${#BREW_FAILURES[@]} > 0 ))
    then
        echo >&2
        echo >&2 "These Homebrew packages failed:"
        printf >&2 '  - %s\n' "${BREW_FAILURES[@]}"
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
