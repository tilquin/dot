#!/bin/zsh

set -e

if [[ "$OSTYPE" != darwin* ]]
then
    echo "Skipping Maccy settings: not macOS"
    exit 0
fi

domain=org.p0deje.Maccy
maccy_app=/Applications/Maccy.app

if [[ ! -d "$maccy_app" ]]
then
    echo >&2 "Maccy is not installed at $maccy_app"
    exit 1
fi

configure_launch_at_login() {
    if ! osascript - "$maccy_app" <<'APPLESCRIPT'
on run arguments
    set maccyPath to item 1 of arguments

    tell application "System Events"
        set matchingItems to every login item whose path is maccyPath
        if matchingItems is {} then
            make login item at end with properties {path:maccyPath, hidden:false}
        else
            repeat with matchingItem in matchingItems
                set hidden of matchingItem to false
            end repeat
        end if
    end tell
end run
APPLESCRIPT
    then
        echo >&2 "Could not add Maccy as a login item. Run this script from Terminal and allow access to System Events."
        return 1
    fi
}

# General settings: Control-Command-V opens Maccy. The remaining shortcuts
# are Maccy's standard pin, delete, and preview bindings.
defaults write "$domain" KeyboardShortcuts_popup -string '{"carbonKeyCode":9,"carbonModifiers":4352}'
defaults write "$domain" KeyboardShortcuts_pin -string '{"carbonKeyCode":35,"carbonModifiers":2048}'
defaults write "$domain" KeyboardShortcuts_delete -string '{"carbonKeyCode":51,"carbonModifiers":2048}'
defaults write "$domain" KeyboardShortcuts_togglePreview -string '{"carbonKeyCode":49,"carbonModifiers":4096}'
defaults write "$domain" searchMode -string exact
defaults write "$domain" pasteByDefault -bool false
defaults write "$domain" removeFormattingByDefault -bool false
defaults write "$domain" SUEnableAutomaticChecks -bool true

# Preserve the current popup layout and all supported clipboard types.
defaults write "$domain" showFooter -bool true
defaults write "$domain" showSearch -bool true
defaults write "$domain" showTitle -bool true
defaults write "$domain" previewWidth -float 400
defaults write "$domain" windowSize -string '[450,800]'
defaults write "$domain" enabledPasteboardTypes -array \
    public.png \
    public.tiff \
    public.html \
    public.rtf \
    public.jpeg \
    public.file-url \
    public.heic \
    public.utf8-plain-text

configure_launch_at_login

echo "Maccy settings configured; restart Maccy if it is running"
