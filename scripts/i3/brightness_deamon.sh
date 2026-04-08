#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

BACKLIGHT=$(brightnessctl -l | awk -F"'" '/backlight/ {print $2; exit}')
BRIGHTNESS_FILE="/sys/class/backlight/$BACKLIGHT/actual_brightness"

get_backlight() {
    echo $(($(($(brightnessctl g) * 100))/$(brightnessctl m)))
}

du_notify() {
    BRIGHTNESS=$(get_backlight)
    dunstify -a "Brightness" -u low -h string:x-dunst-stack-tag:brightness \
        -i ~/.local/share/icons/Material-Black-Blueberry-Numix-FLAT/48/notifications/notification-display-brightness-full.svg \
        -h int:value:"${BRIGHTNESS}%" "Brightness: "
}

inotifywait -q -m -e modify "$BRIGHTNESS_FILE" |
while read -r _; do
    du_notify
done
