#!/bin/sh
# Slowly pulse the bell-flagged window's status-bar colors while any window
# has an unvisited bell flag. Started (in background) by the alert-bell hook;
# exits and restores the steady highlight once every flag is cleared.
TMUX_BIN=/opt/homebrew/bin/tmux
ON='fg=colour232,bg=colour214,bold'    # highlighted (matches steady style)
OFF='fg=colour214,bg=default,bold'     # dimmed phase of the pulse

# single instance
PIDFILE="$HOME/.tmux/.bell-flash.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  exit 0
fi
echo $$ > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

while "$TMUX_BIN" list-windows -a -F '#{window_bell_flag}' 2>/dev/null | grep -q 1; do
  "$TMUX_BIN" set -g window-status-bell-style "$OFF"
  sleep 1
  "$TMUX_BIN" set -g window-status-bell-style "$ON"
  sleep 1
done
"$TMUX_BIN" set -g window-status-bell-style "$ON"
