#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

AUDIO_DELTA=${AUDIO_DELTA:-5}

move_sinks_to_new_default() {
    pactl list short sink-inputs | awk '{print $1}' |
    while read -r input; do
        pactl move-sink-input "$input" @DEFAULT_SINK@
    done
}

set_default_playback_device_next() {
    local inc=${1:-1}
    mapfile -t sinks < <(pactl list short sinks | awk '{print $1}')

    current=$(pactl get-default-sink)
    for i in "${!sinks[@]}"; do
        [[ "${sinks[$i]}" == "$current" ]] && idx=$i && break
    done

    new_index=$(( (idx + inc + ${#sinks[@]}) % ${#sinks[@]} ))
    pactl set-default-sink "${sinks[$new_index]}"
    move_sinks_to_new_default
}

case "$1" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +"${AUDIO_DELTA}%"
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -"${AUDIO_DELTA}%"
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    next)
        set_default_playback_device_next 1
        ;;
    prev)
        set_default_playback_device_next -1
        ;;
esac
