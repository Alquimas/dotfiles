#!/usr/bin/env bash

# Inspired by the script from ThePrimeagen
# You can find it here:
# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

usage() {
    cat <<'EOF'
Usage: fzftmux.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(find tmux)
    local missing_cmds=()

    for cmd in "${cmds[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            missing_cmds+=("${cmd}")
        fi
    done

    if (( ${#missing_cmds[@]} > 0 )); then
        echo "Error: The following dependencies are missing:" >&2
        print '   - %s\n' "${missing_cmds[@]}" >&2
        exit 1
    fi

    echo "Success: All dependencies (${#cmds[@]}) are met."
}

main () {
    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(find ~/projects -mindepth 1 -maxdepth 1 -type d | fzf)
    fi

    if [[ -z $selected ]]; then
        exit 0
    fi

    selected_name=$(basename "$selected" | tr . _)

    tmux_running=$(pgrep tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s $selected_name -c $selected
        exit 0
    fi


    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmux new-session -ds $selected_name -c $selected
    fi

    tmux switch-client -t $selected_name
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
