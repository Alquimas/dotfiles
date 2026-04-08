#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: brightness.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(brightnessctl awk inotifywait)
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

get_backlight() {
    echo $(( ( $(brightnessctl g) * 100 ) / $(brightnessctl m) ))
}

main() {
    local backlight
    local brightness_file

    backlight=$(brightnessctl -l | awk -F"'" '/backlight/ {print $2; exit}')
    brightness_file="/sys/class/backlight/${backlight}/actual_brightness"

    echo "󰃟 $(get_backlight)%"

    inotifywait -q -m -e modify "${brightness_file}" |
    while read -r _; do
        echo "󰃟 $(get_backlight)%"
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
