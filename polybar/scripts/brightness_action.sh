#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

get_backlight() {
    echo $(($(($(brightnessctl g) * 100))/$(brightnessctl m)))
}

inc_backlight() {
    actual_value=$(get_backlight)
    new_value=$(( actual_value + 3 ))
    brightnessctl s "${new_value}%" > /dev/null 2>&1 && du_notify
}

# Decrease
dec_backlight() {
    actual_value=$(get_backlight)
    new_value=$(( actual_value - 3 ))
    result=$(( new_value > 0 ? new_value : 0 ))
    brightnessctl s "${result}%" > /dev/null 2>&1 && du_notify
}

case "$1" in
    inc)
        inc_backlight
        ;;
    dec)
        dec_backlight
        ;;
esac
