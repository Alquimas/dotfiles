#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: volume_action.sh [-h] [-e] <up|down|mute|next|prev>

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(pactl awk)
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

move_sinks_to_new_default() {
    pactl list short sink-inputs | awk '{print $1}' |
    while read -r input; do
        pactl move-sink-input "${input}" @DEFAULT_SINK@
    done
}

set_default_playback_device_next() {
    local inc=${1:-1}
    local current
    local idx=0
    local new_index

    mapfile -t sinks < <(pactl list short sinks | awk '{print $1}')

    current=$(pactl get-default-sink)
    for i in "${!sinks[@]}"; do
        [[ "${sinks[$i]}" == "${current}" ]] && idx=${i} && break
    done

    new_index=$(( (idx + inc + ${#sinks[@]}) % ${#sinks[@]} ))
    pactl set-default-sink "${sinks[$new_index]}"
    move_sinks_to_new_default
}

main() {
    : "${AUDIO_DELTA:=5}"

    case "${1-}" in
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
        *)
            usage
            exit 1
            ;;
    esac
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

if (( $# != 1 )); then
    usage
    exit 1
fi

main "${1}"
