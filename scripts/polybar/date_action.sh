#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

STATE_FILE="/tmp/personal_token_date_state"

usage() {
    cat <<'EOF'
Usage: date_action.sh [-h] [-e] <toggle>

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(sed expr)
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

toggle_state() {
    local current_state
    local new_state

    current_state=$(sed -n 's/^PERSONAL_TOKEN_DATE_STATE=//p' "${STATE_FILE}")
    new_state=$((3 - "${current_state}"))
    sed -i "s/PERSONAL_TOKEN_DATE_STATE=.*/PERSONAL_TOKEN_DATE_STATE=${new_state}/" "${STATE_FILE}"
}

main() {
    case "${1-}" in
        toggle)
            toggle_state
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
