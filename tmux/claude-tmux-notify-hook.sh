#!/bin/sh
# Claude Code hook -> contextual desktop notification via ~/.tmux/tmux-notify.sh.
#   $1 = event kind: "attention" (Notification hook) | "done" (Stop hook)
# Receives the hook JSON on stdin. Only does anything when running inside tmux.
KIND="${1:-attention}"
INPUT=$(cat)
[ -n "$TMUX_PANE" ] || exit 0

TMUX_BIN=/opt/homebrew/bin/tmux
STATE=$("$TMUX_BIN" display-message -p -t "$TMUX_PANE" \
  '#{session_name}:#{window_index}|#{window_name}|#{session_attached}|#{window_active}|#{window_zoomed_flag}|#{pane_active}' \
  2>/dev/null) || exit 0
IFS='|' read -r TARGET WIN ATTACHED WACTIVE ZOOMED PACTIVE <<EOF
$STATE
EOF

# Visible = session attached + window active + pane not hidden behind a zoom.
VISIBLE=0
if [ "${ATTACHED:-0}" -ge 1 ] && [ "$WACTIVE" = "1" ]; then
  if [ "$ZOOMED" = "0" ] || [ "$PACTIVE" = "1" ]; then
    VISIBLE=1
  fi
fi

if [ "$KIND" = "done" ]; then
  # Skip "finished" notifications for visible panes — you're already looking.
  [ "$VISIBLE" = "1" ] && exit 0
  MSG="✅ Claude finished — $WIN ($TARGET)"
  SOUND=Glass
else
  # "attention" always notifies — missing a permission prompt is costly.
  JQ=$(command -v jq || echo /opt/homebrew/bin/jq)
  DETAIL=$(printf '%s' "$INPUT" | "$JQ" -r '.message // empty' 2>/dev/null)
  MSG="✋ ${DETAIL:-Claude needs your input} — $WIN ($TARGET)"
  SOUND=Ping
fi

exec "$HOME/.tmux/tmux-notify.sh" "$TARGET" "$MSG" "$SOUND" "claude-$KIND-$TARGET"
