#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

STATE_FILE="/tmp/personal_token_date_state"

usage() {
    cat <<'EOF'
Usage: date.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(sed date inotifywait sleep kill)
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

print_date() {
    local state

    state=$(sed -n 's/^PERSONAL_TOKEN_DATE_STATE=//p' "${STATE_FILE}" 2>/dev/null || echo 1)

    if [[ "${state}" == "2" ]]; then
        echo -n '󰃭 '
        date '+%d/%m, %H:%M'
    else
        echo -n '󰃭 '
        date '+%a, %d %b, %H:%M'
    fi
}

main() {
    local inotify_pid
    local sleep_pid

    echo "PERSONAL_TOKEN_DATE_STATE=1" > "${STATE_FILE}"
    print_date

    while true; do
        inotifywait -qq -e modify,create,move,delete "${STATE_FILE}" &
        inotify_pid=$!

        sleep 10 &
        sleep_pid=$!

        wait -n "${inotify_pid}" "${sleep_pid}" || true
        kill "${inotify_pid}" "${sleep_pid}" 2>/dev/null || true

        print_date
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
