#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

for cmd in pactl awk; do
    command -v "$cmd" >/dev/null 2>&1 || exit 1
done

# Configuration
: "${AUDIO_HIGH_SYMBOL:=󰕾}"
: "${AUDIO_MED_SYMBOL:=󰖀}"
: "${AUDIO_LOW_SYMBOL:=󰸈}"
: "${AUDIO_MUTED_SYMBOL:=󰸈}"
: "${AUDIO_MED_THRESH:=50}"
: "${AUDIO_LOW_THRESH:=0}"

get_sink_vol() {
    pactl get-sink-volume @DEFAULT_SINK@ \
        | awk '/front-left:/ {print $5}' | tr -d '%'
}

get_sink_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

print_volume() {
    local VOL MUT
    VOL=$(get_sink_vol)
    MUT=$(get_sink_mute)

    if [[ "$MUT" == "yes" ]]; then
        printf "%s%3d%%\n" "$AUDIO_MUTED_SYMBOL" "$VOL"
    elif (( VOL <= AUDIO_LOW_THRESH )); then
        printf "%s%3d%%\n" "$AUDIO_LOW_SYMBOL" "$VOL"
    elif (( VOL <= AUDIO_MED_THRESH )); then
        printf "%s%3d%%\n" "$AUDIO_MED_SYMBOL" "$VOL"
    else
        printf "%s%3d%%\n" "$AUDIO_HIGH_SYMBOL" "$VOL"
    fi
}

while true; do
    print_volume || true

    pactl subscribe 2>/dev/null | while read -r line; do
        case "$line" in
            *"sink"*|*"server"*)
                print_volume || true
                ;;
        esac
    done

    sleep 1
done
