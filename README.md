Bootstrap my dot files on Mac, Linux, and EC2

    /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/tilquin/dot/master/bootstrap.sh)"

`bootstrap.sh` automatically runs every executable `bootstrap.d/*.sh` file.
Each script can also be run independently, for example:

    ~/Library/dot/bootstrap.d/maccy.sh

## Homebrew

Personal macOS packages are declared in `Brewfile`. Bootstrap checks the bundle
and installs missing packages with `--no-upgrade`. It does not run a general
package upgrade or remove unlisted packages, though Homebrew may still update
dependencies required by a new installation. No company taps or Kitty
configuration are included.

Install or check the bundle independently:

```sh
brew bundle install --file="$HOME/Library/dot/Brewfile" --no-upgrade
brew bundle check --file="$HOME/Library/dot/Brewfile" --no-upgrade
```

After adding or removing packages, edit `Brewfile`, or refresh it from your
installed packages with the helper below. It overwrites the manifest and shows
the Git diff for review. Check for unwanted packages or company taps before
committing:

```sh
"$HOME/Library/dot/bin/brew-bundle-update"
```

`Brewfile` records the desired packages, not an exact version lock.

Run the bundle bootstrap tests without installing packages or changing system
settings:

```sh
zsh -f "$HOME/Library/dot/tests/bootstrap-bundle.zsh"
```

## Headphone toggle

`applescripts/Toggle Headphones.applescript` switches playback between Bluetooth
headphones and built-in speakers without changing the microphone. It discovers
devices classified by macOS as Headphones or Headset, prefers connected devices,
and asks which pair to use if there are several. No personal device names are
stored in the source. Wired and USB headphones are not currently discovered.

It uses `switchaudio-osx` from the Brewfile. To activate an inactive pair, it also
needs the Sound menu-bar icon and Accessibility / System Events Automation
permission for the app.

Build the Spotlight app and run the selection tests:

```sh
make -C "$HOME/Library/dot/applescripts"
make -C "$HOME/Library/dot/applescripts" test
```

The Makefile compiles the headphone app to `~/Applications`, then signs and
verifies it. Run `make` after source edits; unchanged builds are skipped.
Use `make -B` to force a rebuild, or `APPS_DIR="/some/output/directory"` to change
the output location for testing. `make test` runs selection tests without
changing audio output.

macOS may require re-enabling the app's permissions after rebuilding it.
