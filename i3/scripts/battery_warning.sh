#!/usr/bin/env bash

FIRST_PING="20"
LAST_PING="5"
NEXT_PING="${FIRST_PING}"
FIRST_MESSAGE="Battery lower than 20%. Find a charger."
LAST_MESSAGE="Battery lower than 5%, Computer will shutdown soon."
NEXT_MESSAGE="${FIRST_MESSAGE}"
SOUND="${HOME}/.config/i3/scripts/battery_warning.wav"
POPUP_SEEN=""

while true; do

    STATUS=$(cat /sys/class/power_supply/BAT0/status)
    CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)

    if [[ ${STATUS} = "Discharging" ]]; then
        if [[ ${CAPACITY} -le ${NEXT_PING} ]]; then
            paplay "${SOUND}" &
            notify-send -u critical "Low Battery" "${NEXT_MESSAGE}"

            if [[ -z "${POPUP_SEEN}" ]]; then
                POPUP_SEEN="s"
                NEXT_PING="${LAST_PING}"
                NEXT_MESSAGE="${LAST_MESSAGE}"
            else
                NEXT_PING=0
            fi

        fi

    else
        POPUP_SEEN=""
        NEXT_PING="${FIRST_PING}"
        NEXT_MESSAGE="${FIRST_MESSAGE}"
    fi
    sleep 90
done
