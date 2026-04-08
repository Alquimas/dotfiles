#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: keyboard.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(setxkbmap awk xset grep)
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

main() {
    local layout
    local variant
    local caps_on
    local kb

    layout=$(setxkbmap -query | awk '/layout:/ {print $2}')
    variant=$(setxkbmap -query | awk '/variant:/ {print $2}')
    caps_on=$(xset q | grep -q "Caps Lock:\s*on" && echo 1 || echo 0)

    if [[ -n "${variant}" ]]; then
        kb="${layout}(${variant})"
    else
        kb="${layout}"
    fi

    if [[ "${caps_on}" -eq 1 ]]; then
        echo "${kb^^}"
    else
        echo "${kb}"
    fi
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
