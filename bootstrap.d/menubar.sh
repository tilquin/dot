#!/bin/zsh

set -e

if [[ "$OSTYPE" != darwin* ]]
then
    echo "Skipping menu bar settings: not macOS"
    exit 0
fi

for item in Bluetooth Sound
do
    # 18 selects "Always Show in Menu Bar" in Control Center preferences.
    defaults -currentHost write com.apple.controlcenter "$item" -int 18
    defaults write com.apple.controlcenter "NSStatusItem VisibleCC $item" -bool true
done

killall ControlCenter 2>/dev/null || true

echo "Bluetooth and Sound menu bar settings configured; log out and back in if needed"
