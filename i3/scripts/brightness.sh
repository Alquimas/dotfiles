#!/usr/bin/env bash

# Get brightness
get_backlight() {
    echo $(($(($(brightnessctl g) * 100))/$(brightnessctl m)))
}

# Notify
du_notify() {
    BRIGHTNESS=$(get_backlight)
    dunstify -a "Brightness" -u low -h string:x-dunst-stack-tag:brightness \
        -i ~/.local/share/icons/Material-Black-Blueberry-Numix-FLAT/48/notifications/notification-display-brightness-full.svg \
        -h int:value:"${BRIGHTNESS}%" "Value: "
}

# Increase
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
