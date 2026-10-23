#!/bin/zsh
# Exercise only the bundle helper: no package installs or macOS settings changes.
set -eu

task_repo_dir=${0:A:h:h}
eval "$(awk '/^brew_install_bundle\(\) \{/ { capture=1 } capture { print } capture && /^}$/ { exit }' "$task_repo_dir/bootstrap.sh")"

typeset -i BREW_BUNDLE_FAILED=0
typeset -i task_check_status=0
typeset -i task_install_status=0
typeset -a task_brew_calls=()
DOT_DIR="$task_repo_dir"

brew() {
    task_brew_calls+=("${(j: :)@}")
    case "${(j: :)@}" in
        "bundle check --file=$DOT_DIR/Brewfile --no-upgrade")
            return "$task_check_status"
            ;;
        "bundle install --file=$DOT_DIR/Brewfile --no-upgrade")
            return "$task_install_status"
            ;;
        *)
            print -u2 "Unexpected Homebrew call: $*"
            return 99
            ;;
    esac
}

# Already installed: check once, without upgrading or reinstalling.
brew_install_bundle
[[ $BREW_BUNDLE_FAILED == 0 ]]
[[ ${#task_brew_calls[@]} == 1 ]]

# Missing packages: install once, with automatic upgrades disabled.
task_brew_calls=()
task_check_status=1
brew_install_bundle
[[ $BREW_BUNDLE_FAILED == 0 ]]
[[ ${#task_brew_calls[@]} == 2 ]]
[[ ${task_brew_calls[2]} == "bundle install --file=$DOT_DIR/Brewfile --no-upgrade" ]]

# Installation failure is recorded without preventing other bootstrap tasks.
task_brew_calls=()
task_install_status=7
brew_install_bundle
[[ $BREW_BUNDLE_FAILED == 1 ]]
[[ ${#task_brew_calls[@]} == 2 ]]

# Missing manifest fails clearly, without calling Homebrew.
task_missing_dir=$(mktemp -d /private/tmp/bootstrap-bundle-check.XXXXXX)
trap 'rmdir "$task_missing_dir"' EXIT
DOT_DIR="$task_missing_dir"
BREW_BUNDLE_FAILED=0
task_brew_calls=()
brew_install_bundle
[[ $BREW_BUNDLE_FAILED == 1 ]]
[[ ${#task_brew_calls[@]} == 0 ]]

print '4 bundle bootstrap tests passed; no packages or system settings changed.'
