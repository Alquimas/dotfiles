#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

STATE_FILE="/tmp/personal_token_date_state"
PERSONAL_TOKEN_DATE_STATE=$(sed -n 's/^PERSONAL_TOKEN_DATE_STATE=//p' "${STATE_FILE}")

toggle_state() {
    NEW_STATE=$(expr 3 - "${PERSONAL_TOKEN_DATE_STATE}")
    sed -i "s/PERSONAL_TOKEN_DATE_STATE=.*/PERSONAL_TOKEN_DATE_STATE=${NEW_STATE}/" "${STATE_FILE}"
    PERSONAL_TOKEN_DATE_STATE=${NEW_STATE}
}

case "$1" in
    toggle)
        toggle_state
        ;;
esac
