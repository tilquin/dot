#!/bin/zsh
# Test only the SSH wrapper; don't load shell startup files or connect anywhere.
set -eu

task_repo_dir=${0:A:h:h}
eval "$(awk '/^function ssh \{/ { capture=1 } capture { print } capture && /^}$/ { exit }' "$task_repo_dir/etc/zshrc")"

# Substitute printenv for the SSH executable to observe the child's environment.
task_stub_dir=$(mktemp -d /private/tmp/ssh-terminal-check.XXXXXX)
cleanup() {
  unlink "$task_stub_dir/ssh"
  rmdir "$task_stub_dir"
}
trap cleanup EXIT
ln -s /usr/bin/printenv "$task_stub_dir/ssh"
PATH="$task_stub_dir:$PATH"

for task_terminal in xterm-kitty kitty; do
  export TERM="$task_terminal"
  [[ "$(ssh TERM)" == xterm-256color ]]
  [[ "$TERM" == "$task_terminal" ]]
done

for task_terminal in xterm-256color screen-256color vt100; do
  export TERM="$task_terminal"
  [[ "$(ssh TERM)" == "$task_terminal" ]]
  [[ "$TERM" == "$task_terminal" ]]
done

# Arguments pass through, and the underlying command's failure is preserved.
export TERM=xterm-kitty
export TASK_SSH_ARGUMENT='argument with spaces'
[[ "$(ssh TASK_SSH_ARGUMENT)" == 'argument with spaces' ]]
ssh TERM > /dev/null
[[ "$TERM" == xterm-kitty ]]
if ssh TASK_SSH_VARIABLE_THAT_IS_UNSET; then
  print -u2 'SSH wrapper swallowed a failure'
  exit 1
else
  [[ $? == 1 ]]
fi

unset TERM
if ssh TERM; then
  print -u2 'SSH wrapper supplied TERM outside Kitty'
  exit 1
else
  [[ $? == 1 ]]
fi
[[ ! -v TERM ]]

print 'SSH terminal tests passed; no network connections or startup files used.'
