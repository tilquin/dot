#!/bin/zsh

set -e

if [[ "$OSTYPE" != darwin* ]]
then
    echo "Skipping keyboard settings: not macOS"
    exit 0
fi

defaults -currentHost write -g com.apple.keyboard.modifiermapping.0-0-0 -dict 0 -int 2

# Reproduce the modifier-key layout for the Logitech external keyboard
# (vendor 1133, product 50475). These are the values written by macOS under
# System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys.
defaults -currentHost write -g com.apple.keyboard.modifiermapping.1133-50475-0 -array \
    '{ HIDKeyboardModifierMappingSrc = 30064771296; HIDKeyboardModifierMappingDst = 30064771298; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771298; HIDKeyboardModifierMappingDst = 30064771299; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771302; HIDKeyboardModifierMappingDst = 30064771303; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771299; HIDKeyboardModifierMappingDst = 30064771298; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771129; HIDKeyboardModifierMappingDst = 30064771300; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771303; HIDKeyboardModifierMappingDst = 30064771302; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771300; HIDKeyboardModifierMappingDst = 30064771302; }'

hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' > /dev/null

echo "Keyboard settings are configured; reconnect the external keyboard if needed"
