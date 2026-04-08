#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: brightness_action.sh [-h] [-e] <inc|dec>

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(brightnessctl)
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

inc_backlight() {
    local actual_value
    local new_value

    actual_value=$(get_backlight)
    new_value=$(( actual_value + 3 ))
    brightnessctl s "${new_value}%" > /dev/null 2>&1
}

dec_backlight() {
    local actual_value
    local new_value
    local result

    actual_value=$(get_backlight)
    new_value=$(( actual_value - 3 ))
    result=$(( new_value > 0 ? new_value : 0 ))
    brightnessctl s "${result}%" > /dev/null 2>&1
}

main() {
    case "${1-}" in
        inc)
            inc_backlight
            ;;
        dec)
            dec_backlight
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
