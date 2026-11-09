#!/bin/zsh
# Mock preferences/HID commands: no real keyboard settings are changed.
set -eu

task_repo_dir=${0:A:h:h}
task_keyboard_script="$task_repo_dir/bootstrap.d/keyboard.sh"
typeset -i task_native_exists=1
typeset -a task_preference_calls=() task_hid_calls=()

defaults() {
  task_preference_calls+=("${(j: :)@}")
  if [[ "$*" == '-currentHost read -g com.apple.keyboard.modifiermapping.0-0-0' ]]; then
    (( task_native_exists ))
  elif [[ "$*" == '-currentHost delete -g com.apple.keyboard.modifiermapping.0-0-0' ]]; then
    task_native_exists=0
  elif [[ "$*" == '-currentHost write -g com.apple.keyboard.modifiermapping.1133-50475-0 -array '* ]]; then
    return 0
  else
    print -u2 "Unexpected defaults call: $*"
    return 99
  fi
}

hidutil() { task_hid_calls+=("${(j: :)@}"); }

run_keyboard_recipe() {
  setopt localoptions
  local OSTYPE=darwin
  source "$task_keyboard_script"
}

task_native_clear='property --matching {"VendorID":0,"ProductID":0,"PrimaryUsagePage":1,"PrimaryUsage":6} --set {"HIDKeyboardModifierMappingPairs":[],"UserKeyMapping":[]}'
task_logitech_mapping='property --matching {"VendorID":1133,"ProductID":50475,"PrimaryUsagePage":1,"PrimaryUsage":6} --set {"HIDKeyboardModifierMappingPairs":[],"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771296},{"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},{"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771299},{"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302},{"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771303}]}'
task_expected_pairs=(
  '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771296</integer></dict>'
  '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771299</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771298</integer></dict>'
  '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771298</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771299</integer></dict>'
  '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771303</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771302</integer></dict>'
  '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771302</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771303</integer></dict>'
)
task_saved_mapping="-currentHost write -g com.apple.keyboard.modifiermapping.1133-50475-0 -array ${(j: :)task_expected_pairs}"

run_keyboard_recipe
[[ ${#task_preference_calls[@]} == 3 ]]
[[ ${task_preference_calls[2]} == '-currentHost delete -g com.apple.keyboard.modifiermapping.0-0-0' ]]
[[ ${task_preference_calls[3]} == "$task_saved_mapping" ]]
[[ ${#task_hid_calls[@]} == 2 ]]
[[ ${task_hid_calls[1]} == "$task_native_clear" ]]
[[ ${task_hid_calls[2]} == "$task_logitech_mapping" ]]

# Re-running with no saved native override is harmless and adds no global remap.
task_preference_calls=()
task_hid_calls=()
run_keyboard_recipe
[[ ${#task_preference_calls[@]} == 2 ]]
[[ ${task_preference_calls[2]} == "$task_saved_mapping" ]]
[[ ${#task_hid_calls[@]} == 2 ]]
[[ ${task_hid_calls[1]} == "$task_native_clear" ]]
[[ ${task_hid_calls[2]} == "$task_logitech_mapping" ]]

# Non-macOS must exit without invoking either command.
task_nonmac_output=$(
  OSTYPE=linux-gnu
  source "$task_keyboard_script"
  exit 99
)
[[ "$task_nonmac_output" == 'Skipping keyboard settings: not macOS' ]]

print 'Keyboard tests passed: native keyboard unmodified, K860 Caps/Command/Option mappings scoped to one live layer, repeatable, and no global remaps.'
