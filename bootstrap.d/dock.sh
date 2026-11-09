#!/bin/zsh

set -e

if [[ "$OSTYPE" != darwin* ]]
then
    echo "Skipping Dock settings: not macOS"
    exit 0
fi

dock_autohide=$(defaults read com.apple.dock autohide 2>/dev/null || true)
if [[ "$dock_autohide" == 1 || "$dock_autohide" == true ]]
then
    echo "Dock auto-hide is already enabled"
else
    defaults write com.apple.dock autohide -bool true
    # The Dock restarts automatically. It may not be running in a headless session.
    killall Dock 2>/dev/null || true
    echo "Dock auto-hide enabled"
fi
