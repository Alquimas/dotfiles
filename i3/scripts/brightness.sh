#!/usr/bin/env bash

# Get brightness
get_backlight() {
    BNESS=$(xbacklight -get)
    LIGHT=${BNESS%.*}
    echo "${LIGHT}"
}

# Notify
du_notify() {
    BRIGHTNESS=$(get_backlight)
    dunstify -a "popup" -u low -h string:x-dunst-stack-tag:brightness \
        -i ~/.icons/Material-Black-Blueberry-Numix-FLAT/48/notifications/notification-display-brightness-full.svg \
        -h int:value:"${BRIGHTNESS}" "Brightness:"
}

# Increase brightness
inc_backlight() {
    xbacklight -inc 5 && du_notify
}

# Decrease brightness
dec_backlight() {
    xbacklight -dec 5 && du_notify
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
    get_backlight
elif [[ "$1" == "--inc" ]]; then
    inc_backlight
elif [[ "$1" == "--dec" ]]; then
    dec_backlight
else
    get_backlight
fi
