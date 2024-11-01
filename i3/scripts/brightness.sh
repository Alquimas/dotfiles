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
        -i ~/.local/share/icons/Material-Black-Blueberry-Numix-FLAT/48/notifications/notification-display-brightness-full.svg \
        -h int:value:"${BRIGHTNESS}" "Brightness:"
}

# Increase
inc_backlight() {
    xbacklight -inc 3 && du_notify
}

# Decrease
dec_backlight() {
    xbacklight -dec 3 && du_notify
}

# For usage with i3blocks
case "$BLOCK_BUTTON" in
    1) ;;
    2) ;;
    3) ;;
    4) inc_backlight ;;
    5) dec_backlight ;;
esac

# Execute
if [[ "$1" == "--get" ]]; then
    get_backlight
fi
if [[ "$1" == "--inc" ]]; then
    inc_backlight
fi
if [[ "$1" == "--dec" ]]; then
    dec_backlight
fi
