#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

BACKLIGHT=$(brightnessctl -l | awk -F"'" '/backlight/ {print $2; exit}')
BRIGHTNESS_FILE="/sys/class/backlight/$BACKLIGHT/actual_brightness"

get_backlight() {
    echo $(($(($(brightnessctl g) * 100))/$(brightnessctl m)))
}

echo "󰃟 $(get_backlight)%"

inotifywait -q -m -e modify "$BRIGHTNESS_FILE" |
while read -r _; do
    echo "󰃟 $(get_backlight)%"
done
