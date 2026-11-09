#!/bin/zsh
# Mock commands while running the real recipe: no Dock or preferences changes.
set -eu

task_repo_dir=${0:A:h:h}
task_dock_script="$task_repo_dir/bootstrap.d/dock.sh"
task_dock_value=0
typeset -i task_read_status=0
typeset -i task_write_status=0
typeset -i task_restart_status=0
typeset -a task_dock_calls=()

defaults() {
    case "${(j: :)@}" in
        'read com.apple.dock autohide')
            print -r -- "$task_dock_value"
            return "$task_read_status"
            ;;
        'write com.apple.dock autohide -bool true')
            task_dock_calls+=("defaults ${(j: :)@}")
            return "$task_write_status"
            ;;
        *) return 99 ;;
    esac
}

killall() {
    task_dock_calls+=("killall ${(j: :)@}")
    [[ "$*" == Dock ]] || return 99
    return "$task_restart_status"
}

# Source in a function with local shell options: mock commands stay in-process.
run_dock_recipe() {
    setopt localoptions
    source "$task_dock_script"
}

# Disabled: write only autohide, then restart only the Dock.
run_dock_recipe
[[ "${(j:|:)task_dock_calls}" == 'defaults write com.apple.dock autohide -bool true|killall Dock' ]]

# Enabled (both boolean representations): don't write or restart again.
for task_dock_value in 1 true
do
    task_dock_calls=()
    run_dock_recipe
    [[ ${#task_dock_calls[@]} == 0 ]]
done

# Missing preference: enable it. A headless session without a Dock is harmless.
task_dock_value=''
task_read_status=1
task_restart_status=1
task_dock_calls=()
run_dock_recipe
[[ "${(j:|:)task_dock_calls}" == 'defaults write com.apple.dock autohide -bool true|killall Dock' ]]

# A failed write must stop the standalone recipe before attempting a restart.
# Run in a subshell so the recipe's errexit cannot terminate this test suite.
task_write_status=7
set +e
(run_dock_recipe) > /dev/null 2>&1
task_failure_status=$?
set -e
[[ "$task_failure_status" == 7 ]]

# Non-macOS exits before attempting any commands.
task_nonmac_output=$(
    OSTYPE=linux-gnu
    run_dock_recipe
    exit 99
)
[[ "$task_nonmac_output" == 'Skipping Dock settings: not macOS' ]]

print '6 Dock bootstrap cases passed; no system settings changed.'
