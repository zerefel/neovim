#!/bin/sh
# Runs when a tmux attention notification is clicked: focus Ghostty and jump
# to the window that rang the bell. $1 = tmux target ("session:window_index").
# Runs from terminal-notifier with a minimal launchd PATH, so use absolute paths.
TMUX_BIN=/opt/homebrew/bin/tmux
TARGET="$1"

/usr/bin/open -b com.mitchellh.ghostty

[ -n "$TARGET" ] || exit 0
for c in $("$TMUX_BIN" list-clients -F '#{client_name}' 2>/dev/null); do
  "$TMUX_BIN" switch-client -c "$c" -t "$TARGET" 2>/dev/null
done
