# tmux config

tmux configuration and the "attention notification" setup that pairs with
Claude Code running in multiple panes. Two complementary signals:

- **Orange window flag** (tmux status bar): any pane ringing the terminal bell
  flags its window bold orange until visited.
- **Contextual macOS notifications**: Claude Code hooks post
  "✋ Claude needs your permission to use X" (Ping sound) and
  "✅ Claude finished" (Glass sound) notifications naming the exact window.
  Clicking one focuses Ghostty and jumps straight to that tmux window, even if
  the pane is hidden behind a zoomed pane (`prefix+z`). "Finished"
  notifications are suppressed when the pane is currently visible.

## Files

| File | Installs to | Purpose |
|---|---|---|
| `tmux.conf` | `~/.tmux.conf` | Main config (prefix `C-a`, vim keys, plugins, bell flag) |
| `tmux-notify.sh` | `~/.tmux/tmux-notify.sh` | Posts a macOS notification with click-to-jump (target, message, sound, group) |
| `tmux-notify-click.sh` | `~/.tmux/tmux-notify-click.sh` | Runs when the notification is clicked; focuses Ghostty and switches every tmux client to the target window |
| `claude-tmux-notify-hook.sh` | `~/.claude/hooks/tmux-notify-hook.sh` | Claude Code Notification/Stop hook: builds the contextual message, detects its own pane/visibility, calls `tmux-notify.sh` |

## Restore on a new machine

```sh
# 1. Config + scripts
cp tmux.conf ~/.tmux.conf
mkdir -p ~/.tmux ~/.claude/hooks
cp tmux-notify.sh tmux-notify-click.sh ~/.tmux/
cp claude-tmux-notify-hook.sh ~/.claude/hooks/tmux-notify-hook.sh
chmod +x ~/.tmux/tmux-notify*.sh ~/.claude/hooks/tmux-notify-hook.sh

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

Two things in `~/.claude/settings.json`:

1. `"preferredNotifChannel": "terminal_bell"` — makes Claude ring the bell
   when it wants attention, which drives the orange tmux window flag.
2. Hooks that post the contextual desktop notifications (merge into the
   existing `"hooks"` object):

```json
"Notification": [
  { "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/tmux-notify-hook.sh\" attention", "timeout": 10, "async": true } ] }
],
"Stop": [
  { "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/tmux-notify-hook.sh\" done", "timeout": 10, "async": true } ] }
]
```

To stop getting "finished" notifications, delete the `Stop` block; to stop
"needs input/permission" ones, delete the `Notification` block. New Claude
sessions pick up settings changes (or open `/hooks` once in a running one).

## How the notification chain works

**Orange flag:** a bell (`\a`) in any pane + `monitor-bell on` +
`bell-action any` flags the window; `window-status-bell-style` (set *after*
tpm so the tmux-power theme can't override it) renders it bold orange. The
tmux `alert-bell` hook is deliberately empty — desktop notifications come
from the Claude hooks below, so other tools' bells only flag.

**Desktop notifications:**

1. Claude Code fires its `Notification` (needs permission/input) or `Stop`
   (turn finished) hook, which runs `tmux-notify-hook.sh` inside the pane's
   environment.
2. The hook script reads `$TMUX_PANE` to find its own `session:window`,
   builds a contextual message (✋ with the actual permission text / ✅
   finished), and skips "finished" when the pane is currently visible
   (active window, not hidden behind another pane's zoom).
3. It calls `tmux-notify.sh`, which posts the notification via the rebranded
   app with `-execute 'tmux-notify-click.sh <target>'`.
4. Clicking the notification runs `tmux-notify-click.sh`, which `open`s
   Ghostty and `tmux switch-client`s every attached client to the target
   window. (Runs with launchd's minimal PATH, hence the absolute
   `/opt/homebrew/bin/tmux` path inside.)
