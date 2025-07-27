#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

for cmd in pactl awk; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    }
done

# Default configuration
: "${AUDIO_HIGH_SYMBOL:=󰕾}"
: "${AUDIO_MED_SYMBOL:=󰖀}"
: "${AUDIO_LOW_SYMBOL:=󰸈}"
: "${AUDIO_MUTED_SYMBOL:=󰸈}"
: "${AUDIO_MED_THRESH:=50}"
: "${AUDIO_LOW_THRESH:=0}"
: "${AUDIO_DELTA:=5}"

# Print usage and options
print_help() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -H SYMBOL   Set high-volume symbol      (default: '${AUDIO_HIGH_SYMBOL}')
  -M SYMBOL   Set medium-volume symbol    (default: '${AUDIO_MED_SYMBOL}')
  -L SYMBOL   Set low-volume symbol       (default: '${AUDIO_LOW_SYMBOL}')
  -X SYMBOL   Set muted-symbol            (default: '${AUDIO_MUTED_SYMBOL}')
  -T PERCENT  Medium volume threshold     (default: ${AUDIO_MED_THRESH}%)
  -t PERCENT  Low volume threshold        (default: ${AUDIO_LOW_THRESH}%)
  -i DELTA    Volume change increment     (default: ${AUDIO_DELTA}%)
  -h          Show this help message and exit

Mouse‐click & scroll actions (when run under i3blocks):
  Button 1 (left click)    -> Next sink
  Button 2 (middle click)  -> Toggle mute
  Button 3 (right click)   -> Previous sink
  Button 4 (scroll up)     -> Increase volume by DELTA
  Button 5 (scroll down)   -> Decrease volume by DELTA
EOF
}

# Helpers using pactl

# List all sink names
function get_sinks() {
    pactl list short sinks | awk '{print $1}'
}

# Get volume percentage of a sink
function get_sink_vol() {
    local sink=$1

    pactl get-sink-volume "$sink" | awk '/front-left:/ {print $5}' | tr -d '%'
}

# Get muted status of a sink
function get_sink_mute() {
    local sink=$1

    pactl get-sink-mute "$sink" | awk '{print $2}'
}

# Move all sinks default
function move_sinks_to_new_default() {
    pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
        pactl move-sink-input "$input" @DEFAULT_SINK@
    done
}

# Go to next or previous sink, and them set all sinks to it
function set_default_playback_device_next() {
    local inc sinks current current_index
    inc=${1:-1}
    readarray -t sinks < <(pactl list short sinks | awk '{print $1}')
    current=$(pactl list short sinks | grep "$(pactl get-default-sink)" | awk '{print $1}')
    current_index=-1

    for i in "${!sinks[@]}"; do
        if [[ "${sinks[$i]}" == "$current" ]]; then
            current_index=$i
            break
        fi
    done

    if [[ $current_index -eq -1 ]]; then
        return 1
    fi

    local new_index=$(( (current_index + inc + ${#sinks[@]}) % ${#sinks[@]} ))
    local new_sink="${sinks[$new_index]}"

    pactl set-default-sink "$new_sink"
    move_sinks_to_new_default
}

# Parse options
while getopts "H:M:L:X:T:t:i:h" opt; do
    case "$opt" in
        H) AUDIO_HIGH_SYMBOL="$OPTARG" ;;
        M) AUDIO_MED_SYMBOL="$OPTARG" ;;
        L) AUDIO_LOW_SYMBOL="$OPTARG" ;;
        X) AUDIO_MUTED_SYMBOL="$OPTARG" ;;
        T) AUDIO_MED_THRESH="$OPTARG" ;;
        t) AUDIO_LOW_THRESH="$OPTARG" ;;
        i) AUDIO_DELTA="$OPTARG" ;;
        h) print_help; exit 0 ;;
        *) exit 1 ;;
    esac
done

print_volume() {
    local VOL MUT
    VOL=$(get_sink_vol @DEFAULT_SINK@)
    MUT=$(get_sink_mute @DEFAULT_SINK@)


    if [[ "${MUT}" =~ "yes" ]]; then
        printf "${AUDIO_MUTED_SYMBOL}%3d%%" "${VOL}"
        return 0
    fi

    if [[ "${VOL}" -le "${AUDIO_LOW_THRESH}" ]]; then
        printf "${AUDIO_LOW_SYMBOL}%3d%%" "${VOL}"
        return 0
    fi


    if [[ "${VOL}" -le "${AUDIO_MED_THRESH}" ]]; then
        printf "${AUDIO_MED_SYMBOL}%3d%%" "${VOL}"
        return 0
    fi

    printf "${AUDIO_HIGH_SYMBOL}%3d%%" "${VOL}"
}

function raise_volume() {
    local volume
    volume=$(get_sink_vol @DEFAULT_SINK@)

    if (( volume + AUDIO_DELTA > 120 )); then
        volume=120
    else
        ((volume=volume + AUDIO_DELTA))
    fi

    pactl set-sink-volume @DEFAULT_SINK@ "${volume}%"
}

# Handle click events
case "${BLOCK_BUTTON:-}" in
    1) set_default_playback_device_next ;;        # next sink
    2) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;  # toggle mute
    3) set_default_playback_device_next -1 ;;     # previous sink
    4) raise_volume ;;  # volume up
    5) pactl set-sink-volume @DEFAULT_SINK@ -"${AUDIO_DELTA}"% ;;  # volume down
esac

# Initial display
print_volume
