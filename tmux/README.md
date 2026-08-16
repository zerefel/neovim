# tmux config

tmux configuration and the "attention notification" setup that pairs with
Claude Code running in multiple panes: when a pane rings the terminal bell
(e.g. Claude Code waiting for a permission prompt), the tmux window is flagged
bold orange in the status bar **and** a macOS notification pops up — clicking
it focuses Ghostty and jumps straight to the window that rang the bell, even
if the pane is hidden behind a zoomed pane (`prefix+z`).

## Files

| File | Installs to | Purpose |
|---|---|---|
| `tmux.conf` | `~/.tmux.conf` | Main config (prefix `C-a`, vim keys, plugins, bell alerts) |
| `tmux-notify.sh` | `~/.tmux/tmux-notify.sh` | Called by the `alert-bell` hook; posts the macOS notification |
| `tmux-notify-click.sh` | `~/.tmux/tmux-notify-click.sh` | Runs when the notification is clicked; focuses Ghostty and switches every tmux client to the target window |

## Restore on a new machine

```sh
# 1. Config + scripts
cp tmux.conf ~/.tmux.conf
mkdir -p ~/.tmux
cp tmux-notify.sh tmux-notify-click.sh ~/.tmux/
chmod +x ~/.tmux/tmux-notify*.sh

# 2. Plugin manager (then prefix+I inside tmux to install plugins)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

tmux-continuum (installed via tpm, with `@continuum-boot on`) creates a
LaunchAgent so tmux auto-starts at login and restores sessions after reboot.

### Rebranded notifier app

Notifications are posted by a local copy of
[terminal-notifier](https://github.com/julienXX/terminal-notifier) rebranded
as **"tmux"** with Ghostty's icon, living at `~/Applications/tmux-notifier.app`.
A plain `osascript` notification opens Finder when clicked, and
terminal-notifier's `-sender` flag breaks `-execute` click actions — the
rebranded copy is the only way to get both a nice name/icon *and*
click-to-jump. To recreate it:

```sh
brew install terminal-notifier
mkdir -p ~/Applications
cp -R "$(brew --prefix terminal-notifier)/terminal-notifier.app" ~/Applications/tmux-notifier.app
APP=~/Applications/tmux-notifier.app
cp /Applications/Ghostty.app/Contents/Resources/Ghostty.icns "$APP/Contents/Resources/tmux.icns"
/usr/libexec/PlistBuddy \
  -c 'Set :CFBundleName tmux' \
  -c 'Set :CFBundleIdentifier com.zrfl.tmux-notifier' \
  -c 'Set :CFBundleIconFile tmux' \
  "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDisplayName string tmux' "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"   # required after editing the bundle
brew uninstall terminal-notifier          # the copy is self-contained
```

Notes:
- macOS will ask for notification permission for "tmux" on first use — allow
  it (System Settings → Notifications). Changing the bundle again means a new
  permission grant.
- `brew upgrade` never touches the copy; re-run the block above to refresh it.
- If the app copy is missing, `tmux-notify.sh` falls back to an OSC 777
  notification through Ghostty (click focuses Ghostty, no window jump), then
  to `osascript`.

### Claude Code side

The chain is triggered by the terminal bell, so Claude Code must be configured
to ring it. In `~/.claude/settings.json`:

```json
{ "preferredNotifChannel": "terminal_bell" }
```

## How the notification chain works

1. A program rings the bell (`\a`) in some pane.
2. `monitor-bell on` + `bell-action any` make tmux flag that window;
   `window-status-bell-style` (set *after* tpm so the tmux-power theme can't
   override it) renders the flag bold orange.
3. The `alert-bell` hook runs
   `tmux-notify.sh "<session>:<window_index>" "<message>"`.
4. `tmux-notify.sh` posts a notification via the rebranded app with
   `-execute 'tmux-notify-click.sh <target>'`.
5. Clicking the notification runs `tmux-notify-click.sh`, which `open`s
   Ghostty and `tmux switch-client`s every attached client to the target
   window. (It runs with launchd's minimal PATH, hence the absolute
   `/opt/homebrew/bin/tmux` path inside.)

Ghostty deliberately suppresses notifications for the surface you're currently
looking at, so bells you can already see don't ping you.
