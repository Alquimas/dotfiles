#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: volume.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(pactl awk tr sleep)
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
    pactl get-sink-volume @DEFAULT_SINK@ \
        | awk '/front-left:/ {print $5}' | tr -d '%'
}

get_sink_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

print_volume() {
    local vol
    local mute

    vol=$(get_sink_vol)
    mute=$(get_sink_mute)

    if [[ "${mute}" == "yes" ]]; then
        printf "%s%3d%%\n" "${AUDIO_MUTED_SYMBOL}" "${vol}"
    elif (( vol <= AUDIO_LOW_THRESH )); then
        printf "%s%3d%%\n" "${AUDIO_LOW_SYMBOL}" "${vol}"
    elif (( vol <= AUDIO_MED_THRESH )); then
        printf "%s%3d%%\n" "${AUDIO_MED_SYMBOL}" "${vol}"
    else
        printf "%s%3d%%\n" "${AUDIO_HIGH_SYMBOL}" "${vol}"
    fi
}

main() {
    : "${AUDIO_HIGH_SYMBOL:=󰕾}"
    : "${AUDIO_MED_SYMBOL:=󰖀}"
    : "${AUDIO_LOW_SYMBOL:=󰸈}"
    : "${AUDIO_MUTED_SYMBOL:=󰸈}"
    : "${AUDIO_MED_THRESH:=50}"
    : "${AUDIO_LOW_THRESH:=0}"

    while true; do
        print_volume || true

        pactl subscribe 2>/dev/null | while read -r line; do
            case "${line}" in
                *"sink"*|*"server"*)
                    print_volume || true
                    ;;
            esac
        done

        sleep 1
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
