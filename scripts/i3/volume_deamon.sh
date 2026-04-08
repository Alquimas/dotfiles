#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

ICON_PATH="${HOME}/.local/share/icons/Material-Black-Blueberry-Numix-FLAT/24/status"

usage() {
    cat <<'EOF'
Usage: volume_deamon.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(pactl dunstify awk grep)
    local missing_cmds=()

    for cmd in "${cmds[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_cmds+=("$cmd")
        fi
    done

    if (( ${#missing_cmds[@]} > 0 )); then
        echo "Error: The following dependencies are missing:" >&2
        printf '   - %s\n' "${missing_cmds[@]}" >&2
        exit 1
    fi

    echo "Success: All dependencies (${#cmds[@]}) are met."
}

get_sink_vol() {
    pactl get-sink-volume "${1}" | awk '/front-left:/ { gsub(/[%]/,"",$5); print $5 }'
}

get_sink_mute() {
    pactl get-sink-mute "${1}" | awk '{print $2}'
}

get_sink_name() {
    pactl get-default-sink
}

get_sink_description() {
    pactl list sinks | grep -A 2 "Name: ${1}" | grep 'Description:' | awk -F': ' '{print $2}'
}

notify_volume() {
    local sink=$1
    local volume=$2
    local mute=$3
    local icon

    if [[ "${mute}" =~ yes ]]; then
        icon="${ICON_PATH}/audio-volume-muted-panel.svg"
    else
        icon="${ICON_PATH}/audio-volume-high.svg"
    fi

    dunstify -a "Volume" -u low -h string:x-dunst-stack-tag:volume \
        -i "${icon}" \
        -h int:value:"${volume}%" "Volume: " \
        "${sink}"
}

treat_event() {
    local current_sink
    local current_volume
    local current_mute
    local description

    current_sink="$(get_sink_name)"
    current_volume="$(get_sink_vol @DEFAULT_SINK@)"
    current_mute="$(get_sink_mute @DEFAULT_SINK@)"

    if [[ "${current_sink}" != "${last_sink}" || "${current_volume}" != "${last_volume}" || "${current_mute}" != "${last_mute}" ]]; then
        description="$(get_sink_description "${current_sink}")"
        notify_volume "${description}" "${current_volume}" "${current_mute}"
        last_sink="${current_sink}"
        last_volume="${current_volume}"
        last_mute="${current_mute}"
    fi
}

main() {
    last_volume="$(get_sink_vol @DEFAULT_SINK@)"
    last_mute="$(get_sink_mute @DEFAULT_SINK@)"
    last_sink="$(get_sink_name)"

    pactl subscribe | while read -r line; do
        echo "${line}"
        case "${line}" in
            *"Event 'change' on sink"*) treat_event ;;
            *"Event 'new' on sink"*) treat_event ;;
            *"Event 'change' on server"*) treat_event ;;
            *) continue ;;
        esac
    done
}

while getopts ':he' opt; do
    case "${opt}" in
        h)
            usage
            exit 0
            ;;
        e)
            check_dependencies
            exit 0
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if (( $# > 0 )); then
    usage
    exit 1
fi

main
