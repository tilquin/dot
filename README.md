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

## Private overrides

Keep host-specific configuration outside this repository in
`~/.config/dot-local/`. The shared tmux config sources `tmux.before` first and
`tmux.after` last. Use the latter for private integrations, environment variables,
and host-specific commands. macOS clipboard defaults remain in the portable
`etc/tmux-macosx.conf`; a private overlay can set `copy-command` for another host
without duplicating the shared Enter and double-click bindings.

Reload tmux configuration in an existing server with:

```sh
tmux source-file ~/.tmux.conf
```

The shared Sapling / Mercurial config includes `slrc.before` first and
`slrc.after` last. Missing files are harmless; later settings override earlier
ones. The shared config intentionally does not set a commit identity. Set it
privately in `~/.config/dot-local/slrc.after`, alongside any host-specific
repository bookmarks, paths, and pull aliases:

```ini
[ui]
username = Your Name <you@example.org>
```

On Sapling installations that use a separate native user config (find it with
`sl configfile --user`), add `%include ~/.slrc` there to load the shared config
and its overlays. Keep native host-specific settings outside the repository.

The shell has equivalent optional `local_before.zshrc` and `local_after.zshrc`
hooks, which are Git-ignored. Private overlays need to be provisioned separately;
bootstrap does not generate or copy them.

The external overlays are not tracked by this repository. Git ignore rules do
not control a separate dotfile sync service; exclude private overlays there too
if they should stay host-local.

Terminal exports, interactive history, history archives, and history databases
are excluded from Git. These exclusions do not remove anything from existing
Git history.
