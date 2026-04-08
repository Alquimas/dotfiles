#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

TARGET_SCRIPT="${HOME}/.config/scripts/i3/fzfub.sh"
ALACRITTY_BIN="${HOME}/.cargo/bin/alacritty"

usage() {
    cat <<'EOF'
Usage: fzfub_wrapper.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local total_dependencies=2
    local missing_cmds=()

    if [[ ! -x "${ALACRITTY_BIN}" ]]; then
        missing_cmds+=("${ALACRITTY_BIN}")
    fi

    if [[ ! -f "${TARGET_SCRIPT}" ]]; then
        missing_cmds+=("${TARGET_SCRIPT}")
    fi

    if (( ${#missing_cmds[@]} > 0 )); then
        echo "Error: The following dependencies are missing:" >&2
        printf '   - %s\n' "${missing_cmds[@]}" >&2
        exit 1
    fi

    echo "Success: All dependencies (${total_dependencies}) are met."
}

main() {
    "${ALACRITTY_BIN}" \
        --class="Alacritty-float" \
        --option='window.dimensions.lines=18' \
        --option='window.opacity=1' \
        -e "${TARGET_SCRIPT}"
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
