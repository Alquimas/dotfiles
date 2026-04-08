#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: set_wallpaper.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(find head feh)
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
    local wallpaper_dir="${HOME}/.config/i3"
    local wallpaper_file

    wallpaper_file=$(find -L "${wallpaper_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)

    if [[ -n "${wallpaper_file}" ]]; then
        feh --bg-fill "${wallpaper_file}"
    else
        echo "No wallpaper found in ${wallpaper_dir}"
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
