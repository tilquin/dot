#!/bin/zsh
# Exercise only recipe discovery: no bootstrap installs or system settings.
set -eu

task_repo_dir=${0:A:h:h}
eval "$(awk '/^run_bootstrap_scripts\(\) \{/ { capture=1 } capture { print } capture && /^}$/ { exit }' "$task_repo_dir/bootstrap.sh")"

task_fixture_dir=$(mktemp -d /private/tmp/bootstrap-scripts-check.XXXXXX)
cleanup() {
    local task_file
    for task_file in "$task_fixture_dir"/bootstrap.d/*.sh(N.) "$task_fixture_dir/output"(N.)
    do
        unlink "$task_file"
    done
    rmdir "$task_fixture_dir/bootstrap.d" "$task_fixture_dir"
}
trap cleanup EXIT
mkdir "$task_fixture_dir/bootstrap.d"
DOT_DIR="$task_fixture_dir"
typeset -a BOOTSTRAP_FAILURES=()

# An empty recipe directory is harmless.
run_bootstrap_scripts > "$task_fixture_dir/output" 2>&1
[[ ${#BOOTSTRAP_FAILURES[@]} == 0 ]]
[[ ! -s "$task_fixture_dir/output" ]]

# Simulate a sync/filesystem that drops execute permissions.
cp "$task_repo_dir"/tests/fixtures/bootstrap-scripts/bootstrap.d/*.sh "$task_fixture_dir/bootstrap.d/"
chmod 600 "$task_fixture_dir"/bootstrap.d/*.sh
for task_file in "$task_fixture_dir"/bootstrap.d/*.sh
do
    [[ ! -x "$task_file" ]]
done
run_bootstrap_scripts > "$task_fixture_dir/output" 2>&1
[[ ${#BOOTSTRAP_FAILURES[@]} == 1 ]]
[[ ${BOOTSTRAP_FAILURES[1]} == 20-failure.sh ]]
[[ "$(<"$task_fixture_dir/output")" == $'Running 10-first.sh\nFIRST fixture\nRunning 20-failure.sh\nFAILURE fixture\nRunning 30-last.sh\nLAST fixture' ]]

print 'Recipe discovery tests passed: empty directory, non-executable zsh recipes, ordering, and continuation after failure.'
