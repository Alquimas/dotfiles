#!/usr/bin/env bash

STATE_FILE="/tmp/personal_token_date_state"

if [[ ! -e "${STATE_FILE}" ]]; then
    touch "${STATE_FILE}"
    echo "PERSONAL_TOKEN_DATE_STATE=1" > "${STATE_FILE}"
fi

PERSONAL_TOKEN_DATE_STATE=$(sed -n 's/^PERSONAL_TOKEN_DATE_STATE=//p' "${STATE_FILE}")

if [[ -z "${PERSONAL_TOKEN_DATE_STATE}" || ! "${PERSONAL_TOKEN_DATE_STATE}" =~ ^[12]$ ]]; then
    PERSONAL_TOKEN_DATE_STATE=1
    echo "PERSONAL_TOKEN_DATE_STATE=1" > "${STATE_FILE}"
fi

toggle_state() {
    NEW_STATE=$(expr 3 - "${PERSONAL_TOKEN_DATE_STATE}")
    sed -i "s/PERSONAL_TOKEN_DATE_STATE=.*/PERSONAL_TOKEN_DATE_STATE=${NEW_STATE}/" "${STATE_FILE}"
    PERSONAL_TOKEN_DATE_STATE=${NEW_STATE}
}

case "${BLOCK_BUTTON}" in
    1) toggle_state ;;
esac

if [[ "${PERSONAL_TOKEN_DATE_STATE}" -eq 1 ]]; then
    echo -n '󰃭 '; date '+%a, %d %b, %H:%M'
else
    echo -n '󰃭 '; date '+%d/%m, %H:%M'
fi
