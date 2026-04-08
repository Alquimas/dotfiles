#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: takeScreenshot.sh [-h] [-e] -t <window|area|all>

  -h    Show this message.
  -e    Check script dependencies and exit.
  -t    Type of screenshot. Supported values are window, area and all.
EOF
}

check_dependencies() {
    local cmds=(date xdg-user-dir mkdir dunstify paplay xclip maim xdotool)
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

notify_shot() {
    local notify_cmd=$1

    eval "${notify_cmd} Copied\ to\ the\ clipboard!"
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
}

copy_shot() {
    local file=$1
    local notify_cmd=$2

    xclip -selection clipboard -t image/png "${file}" && notify_shot "${notify_cmd}"
}

shot_all() {
    local directory=$1
    local file=$2
    local notify_cmd=$3

    cd "${directory}" && maim -u -f png "${file}" && copy_shot "${file}" "${notify_cmd}"
}

shot_window() {
    local directory=$1
    local file=$2
    local notify_cmd=$3

    cd "${directory}" && maim -u -f png -i "$(xdotool getactivewindow)" "${file}" \
        && copy_shot "${file}" "${notify_cmd}"
}

shot_area() {
    local directory=$1
    local file=$2
    local notify_cmd=$3

    cd "${directory}" && maim -u -f png -s -b 1.5 -c 0.3,0.50,0.85,0.25 -l "${file}" \
        && copy_shot "${file}" "${notify_cmd}"
}

main() {
    local type=$1
    local time
    local directory
    local file
    local notify_cmd

    time=$(date +%Y_%m_%d-%T_%3N)
    directory="$(xdg-user-dir PICTURES)/Screenshots"
    file="${time}.png"
    notify_cmd='dunstify -a "popup" -h string:x-dunst-stack-tag:takescreenshot -i ~/.local/share/icons/Material-Black-Blueberry-Numix-FLAT/16/mimetypes/image-png.svg Screenshot'

    if [[ ! -d "${directory}" ]]; then
        mkdir -p "${directory}"
    fi

    case "${type}" in
        window)
            shot_window "${directory}" "${file}" "${notify_cmd}"
            ;;
        area)
            shot_area "${directory}" "${file}" "${notify_cmd}"
            ;;
        all)
            shot_all "${directory}" "${file}" "${notify_cmd}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

TYPE=""
while getopts ':het:' opt; do
    case "${opt}" in
        h)
            usage
            exit 0
            ;;
        e)
            check_dependencies
            exit 0
            ;;
        t)
            TYPE=${OPTARG}
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

main "${TYPE}"
