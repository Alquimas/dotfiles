#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

STATE_FILE="/tmp/personal_token_date_state"
echo "PERSONAL_TOKEN_DATE_STATE=1" > "${STATE_FILE}"

print_date() {
    STATE=$(sed -n 's/^PERSONAL_TOKEN_DATE_STATE=//p' "$STATE_FILE" 2>/dev/null || echo 1)

    if [[ "$STATE" == "2" ]]; then
        echo -n '󰃭 '; date '+%d/%m, %H:%M'
    else
        echo -n '󰃭 '; date '+%a, %d %b, %H:%M'
    fi
}

print_date

while true; do
    inotifywait -qq -e modify,create,move,delete "$STATE_FILE" &
    INOTIFY_PID=$!

    sleep 10 &
    SLEEP_PID=$!

    wait -n "$INOTIFY_PID" "$SLEEP_PID" || true
    kill "$INOTIFY_PID" "$SLEEP_PID" 2>/dev/null || true

    print_date
done
