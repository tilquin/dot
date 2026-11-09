#!/bin/zsh

set -e

if [[ "$OSTYPE" != darwin* ]]
then
    echo "Skipping keyboard settings: not macOS"
    exit 0
fi

# The built-in keyboard must use its native layout. Remove the legacy saved
# override and clear its live mappings without touching other keyboards.
native_preference=com.apple.keyboard.modifiermapping.0-0-0
if defaults -currentHost read -g "$native_preference" > /dev/null 2>&1
then
    defaults -currentHost delete -g "$native_preference"
fi
hidutil property --matching '{"VendorID":0,"ProductID":0,"PrimaryUsagePage":1,"PrimaryUsage":6}' --set '{"HIDKeyboardModifierMappingPairs":[],"UserKeyMapping":[]}' > /dev/null

# Only the Logitech USB receiver (K860) gets remaps: Caps Lock to Control and
# Command/Option swapped on both sides, matching the tested physical labels.
# Keep the keyboard's current Fn/OS mode; switching it changes the input codes.
# XML integer tags are required: OpenStep dictionary values become strings,
# which macOS ignores even though `defaults read` prints the same numbers.
defaults -currentHost write -g com.apple.keyboard.modifiermapping.1133-50475-0 -array \
    '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771296</integer></dict>' \
    '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771299</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771298</integer></dict>' \
    '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771298</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771299</integer></dict>' \
    '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771303</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771302</integer></dict>' \
    '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771302</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771303</integer></dict>'

# Apply the tested mapping to this receiver only. Clear the modifier-pair layer
# so Command/Option are swapped in just one live layer, not both.
# The saved preference is for reconnects; no global HID remap is set.
hidutil property --matching '{"VendorID":1133,"ProductID":50475,"PrimaryUsagePage":1,"PrimaryUsage":6}' --set '{"HIDKeyboardModifierMappingPairs":[],"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771296},{"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},{"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771299},{"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302},{"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771303}]}' > /dev/null

echo "Keyboard settings saved and applied to connected keyboards"
