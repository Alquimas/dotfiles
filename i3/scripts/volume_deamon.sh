#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C
ICON_PATH="${HOME}/.local/share/icons/Material-Black-Blueberry-Numix-FLAT/24/status"
CMDS=(pactl dunstify)

for cmd in "${CMDS[@]}"; do
  command -v "$cmd" >/dev/null || { echo "Error: $cmd not found" >&2; exit 1; }
done

last_volume=""
last_mute=""
last_sink=""

# Get volume percentage of a sink
function get_sink_vol() {
    pactl get-sink-volume "${1}" | awk '/front-left:/ { gsub(/[%]/,"",$5); print $5 }'
}

# Get muted status of a sink
function get_sink_mute() {
    pactl get-sink-mute "${1}" | awk '{print $2}'
}

# Get the name of the default sink
function get_sink_name() {
    pactl get-default-sink
}

# Get the description of a sink
function get_sink_description() {
    pactl list sinks | grep -A 2 "Name: ${1}" | grep 'Description:' | awk -F': ' '{print $2}'
}

function notify_volume() {
    local volume mute
    sink="${1}"
    volume="${2}"
    mute="${3}"

    if [[ "${mute}" =~ "yes" ]]; then
        icon="${ICON_PATH}/audio-volume-muted-panel.svg"
    else
        icon="${ICON_PATH}/audio-volume-high.svg"
    fi

    dunstify -a "Volume" -u low -h string:x-dunst-stack-tag:volume \
        -i "${icon}" \
        -h int:value:"${volume}%" "Volume: " \
        "${sink}"
}

function treat_event() {
    pkill -RTMIN+1 i3blocks

    local current_sink current_volume current_mute
    current_sink="$(get_sink_name)"
    current_volume="$(get_sink_vol @DEFAULT_SINK@)"
    current_mute="$(get_sink_mute @DEFAULT_SINK@)"

    if [[ "${current_sink}" != "${last_sink}" || "${current_volume}" != "${last_volume}" || "${current_mute}" != "${last_mute}" ]]; then
        local description
        description="$(get_sink_description "${current_sink}")"
        notify_volume "${description}" "${current_volume}" "${current_mute}"
        last_sink="${current_sink}"
        last_volume="${current_volume}"
        last_mute="${current_mute}"
    fi

}

# Initial values
last_volume="$(get_sink_vol @DEFAULT_SINK@)"
last_mute="$(get_sink_mute @DEFAULT_SINK@)"
last_sink="$(get_sink_name)"

# Listen to changes
pactl subscribe | while read -r line; do
    echo "$line"
    case "$line" in
        *"Event 'change' on sink"*) treat_event ;;
        *"Event 'new' on sink"*) treat_event ;;
        *"Event 'change' on server"*) treat_event ;;
        *) continue ;;
    esac
done
