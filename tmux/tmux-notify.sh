#!/bin/sh
# Raise a desktop notification. Called from the tmux alert-bell hook in ~/.tmux.conf.
#   $1 = tmux window target ("session:window_index"), used for click-to-jump
#   $2 = notification message
TITLE="tmux"
TARGET="$1"
MSG="${2:-${1:-tmux pane needs attention}}"

# Preferred: our rebranded terminal-notifier copy (shows as "tmux" with the
# Ghostty icon) — clicking the notification jumps straight to the tmux window
# that rang the bell (via the click handler script).
TN="$HOME/Applications/tmux-notifier.app/Contents/MacOS/terminal-notifier"
[ -x "$TN" ] || TN=/opt/homebrew/bin/terminal-notifier
if [ -x "$TN" ]; then
  "$TN" -title "$TITLE" -message "$MSG" -sound Ping \
    -group "tmux-bell-$TARGET" \
    -execute "$HOME/.tmux/tmux-notify-click.sh '$TARGET'" >/dev/null 2>&1
  exit 0
fi

# Fallback 1: OSC 777 through an attached Ghostty client (click focuses Ghostty)
sent=0
for tty in $(tmux list-clients -F '#{client_tty}' 2>/dev/null); do
  if [ -w "$tty" ]; then
    printf '\033]777;notify;%s;%s\033\\' "$TITLE" "$MSG" > "$tty" && sent=1
  fi
done

# Fallback 2: plain macOS notification (no useful click action)
if [ "$sent" -eq 0 ]; then
  ESCAPED=$(printf '%s' "$MSG" | sed 's/\\/\\\\/g; s/"/\\"/g')
  osascript -e "display notification \"$ESCAPED\" with title \"$TITLE\" sound name \"Ping\"" >/dev/null 2>&1
fi
