#!/bin/zsh

set -e

if [[ "$OSTYPE" != darwin* ]]
then
    echo "Skipping Magic Mouse settings: not macOS"
    exit 0
fi

for domain in \
    com.apple.driver.AppleBluetoothMultitouch.mouse \
    com.apple.AppleMultitouchMouse
do
    defaults write "$domain" MouseButtonMode -string TwoButtonSwapped
    defaults write "$domain" UserPreferences -int 1
    # Disable the two-finger double-tap that opens Mission Control (Exposé).
    defaults write "$domain" MouseTwoFingerDoubleTapGesture -int 0
done

echo "Magic Mouse settings configured; reconnect the mouse if needed"
