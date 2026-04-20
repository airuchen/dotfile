#!/bin/bash
# Queries pomo-tui HTTP API and outputs Waybar JSON.
# Falls back gracefully when the server is not running.

STATUS=$(curl -s --max-time 1 http://127.0.0.1:1881/timer/status 2>/dev/null)

if [ -z "$STATUS" ]; then
    echo '{"text": "🍅 --:--", "class": "Offline", "tooltip": "pomo-tui not running"}'
    exit 0
fi

MODE=$(echo "$STATUS"     | jq -r '.Status.mode      // "Idle"')
REMAINING=$(echo "$STATUS" | jq -r '.Status.remaining // 0')
IS_PAUSED=$(echo "$STATUS" | jq -r '.Status.is_paused | tostring')
IS_IDLE=$(echo "$STATUS"   | jq -r '.Status.is_idle   | tostring')
TASK=$(echo "$STATUS"      | jq -r '.Status.task      // ""')

MINS=$((REMAINING / 60))
SECS=$((REMAINING % 60))
TIME=$(printf "%02d:%02d" "$MINS" "$SECS")

if [ "$MODE" = "Work" ]; then ICON="🍅"; else ICON="☕"; fi

if   [ "$IS_IDLE"   = "true" ]; then CLASS="Idle"
elif [ "$IS_PAUSED" = "true" ]; then CLASS="Paused"
else CLASS="$MODE"
fi

TOOLTIP="${TASK:-$MODE}"

printf '{"text": "%s %s", "class": "%s", "tooltip": "%s"}\n' \
    "$ICON" "$TIME" "$CLASS" "$TOOLTIP"
