#!/usr/bin/env bash

# This script defines just a mode for rofi instead of being a self-contained
# executable that launches rofi by itself. This makes it more flexible than
# running rofi inside this script as now the user can call rofi as one pleases.
# For instance:
#
#   rofi -show powermenu -modi powermenu:./rofi-power-menu
#
# See README.md for more information.

set -e
set -u

usage() {
    cat <<'EOF'
rofi-power-menu - a power menu mode for Rofi

Usage: rofi-power-menu [-h] [-e] [--choices CHOICES] [--confirm CHOICES]
                       [--choose CHOICE] [--dry-run] [--symbols|--no-symbols]

Use with Rofi in script mode. For instance, to ask for shutdown or reboot:

  rofi -show menu -modi "menu:rofi-power-menu --choices=shutdown/reboot"

Available options:
  -h,--help            Show this help text.
  -e                   Check script dependencies and exit.
  --dry-run            Don't perform the selected action but print it to stderr.
  --choices CHOICES    Show only the selected choices in the given order. Use /
                       as the separator. Available choices are lockscreen,
                       logout, suspend, hibernate, reboot and shutdown. By
                       default, all available choices are shown.
  --confirm CHOICES    Require confirmation for the given choices only. Use /
                       as the separator. Available choices are lockscreen,
                       logout, suspend, hibernate, reboot and shutdown. By
                       default, only irreversible actions logout, reboot and
                       shutdown require confirmation.
  --choose CHOICE      Preselect the given choice and only ask for a
                       confirmation (if confirmation is set to be requested).
  --[no-]symbols       Show Unicode symbols or not.
  --[no-]text          Show text description or not.
  --symbols-font FONT  Use the given font for symbols.
EOF
}

check_dependencies() {
    local cmds=(getopt loginctl systemctl)
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

if [[ $# -eq 1 ]]; then
    case "${1}" in
        -h|--help)
            usage
            exit 0
            ;;
        -e)
            check_dependencies
            exit 0
            ;;
    esac
fi

# All supported choices
all=(shutdown reboot suspend hibernate logout lockscreen)

# By default, show all (i.e., just copy the array)
show=("${all[@]}")

declare -A texts
texts[lockscreen]="lock screen"
texts[switchuser]="switch user"
texts[logout]="log out"
texts[suspend]="suspend"
texts[hibernate]="hibernate"
texts[reboot]="reboot"
texts[shutdown]="shut down"

declare -A icons
icons[lockscreen]="\Uf033e"
icons[switchuser]="\Uf0019"
icons[logout]="\Uf0343"
icons[suspend]="\Uf04b2"
icons[hibernate]="\Uf02ca"
icons[reboot]="\Uf0709"
icons[shutdown]="\Uf0425"
icons[cancel]="\Uf0156"

declare -A actions
actions[lockscreen]="loginctl lock-session ${XDG_SESSION_ID-}"
#actions[switchuser]="???"
actions[logout]="loginctl terminate-session ${XDG_SESSION_ID-}"
actions[suspend]="systemctl suspend"
actions[hibernate]="systemctl hibernate"
actions[reboot]="systemctl reboot"
actions[shutdown]="systemctl poweroff"

confirmations=(reboot shutdown logout hibernate)
dryrun=false
showsymbols=true
showtext=true

check_valid() {
    shift 1
    for entry in "${@}"; do
        if [ -z "${actions[$entry]+x}" ]; then
            echo "Invalid choice in $1: $entry" >&2
            exit 1
        fi
    done
}

parsed=$(getopt --options=he --longoptions=help,dry-run,confirm:,choices:,choose:,symbols,no-symbols,text,no-text,symbols-font: --name "$0" -- "$@")
if [ $? -ne 0 ]; then
    usage
    exit 1
fi
eval set -- "$parsed"
unset parsed
while true; do
    case "$1" in
        "-h"|"--help")
            usage
            exit 0
            ;;
        "-e")
            check_dependencies
            exit 0
            ;;
        "--dry-run")
            dryrun=true
            shift 1
            ;;
        "--confirm")
            IFS='/' read -ra confirmations <<< "$2"
            check_valid "$1" "${confirmations[@]}"
            shift 2
            ;;
        "--choices")
            IFS='/' read -ra show <<< "$2"
            check_valid "$1" "${show[@]}"
            shift 2
            ;;
        "--choose")
            check_valid "$1" "$2"
            selectionID="$2"
            shift 2
            ;;
        "--symbols")
            showsymbols=true
            shift 1
            ;;
        "--no-symbols")
            showsymbols=false
            shift 1
            ;;
        "--text")
            showtext=true
            shift 1
            ;;
        "--no-text")
            showtext=false
            shift 1
            ;;
        "--symbols-font")
            symbols_font="$2"
            shift 2
            ;;
        "--")
            shift
            break
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

if [ "$showsymbols" = "false" ] && [ "$showtext" = "false" ]; then
    echo "Invalid options: cannot have --no-symbols and --no-text enabled at the same time." >&2
    exit 1
fi

write_message() {
    local icon
    local text

    if [ -z "${symbols_font+x}" ]; then
        icon="<span font_size=\"medium\">$1</span>"
    else
        icon="<span font=\"${symbols_font}\" font_size=\"medium\">$1</span>"
    fi
    text="<span font_size=\"medium\">$2</span>"
    if [ "$showsymbols" = "true" ]; then
        if [ "$showtext" = "true" ]; then
            echo -n "\u200e${icon} \u2068${text}\u2069"
        else
            echo -n "\u200e${icon}"
        fi
    else
        echo -n "$text"
    fi
}

print_selection() {
    echo -e "$1" | $(read -r -d '' entry; echo "echo $entry")
}

declare -A messages
declare -A confirmationMessages
for entry in "${all[@]}"; do
    messages[$entry]=$(write_message "${icons[$entry]}" "${texts[$entry]^}")
done
for entry in "${all[@]}"; do
    confirmationMessages[$entry]=$(write_message "${icons[$entry]}" "Yes, ${texts[$entry]}")
done
confirmationMessages[cancel]=$(write_message "${icons[cancel]}" "No, cancel")

if [ $# -gt 0 ]; then
    selection="${@}"
else
    if [ -n "${selectionID+x}" ]; then
        selection="${messages[$selectionID]}"
    fi
fi

echo -e "\0no-custom\x1ftrue"
echo -e "\0markup-rows\x1ftrue"

if [ -z "${selection+x}" ]; then
    echo -e "\0prompt\x1fPower menu"
    for entry in "${show[@]}"; do
        echo -e "${messages[$entry]}\0icon\x1f${icons[$entry]}"
    done
else
    for entry in "${show[@]}"; do
        if [ "$selection" = "$(print_selection "${messages[$entry]}")" ]; then
            for confirmation in "${confirmations[@]}"; do
                if [ "$entry" = "$confirmation" ]; then
                    echo -e "\0prompt\x1fAre you sure"
                    echo -e "${confirmationMessages[$entry]}\0icon\x1f${icons[$entry]}"
                    echo -e "${confirmationMessages[cancel]}\0icon\x1f${icons[cancel]}"
                    exit 0
                fi
            done
            selection=$(print_selection "${confirmationMessages[$entry]}")
        fi
        if [ "$selection" = "$(print_selection "${confirmationMessages[$entry]}")" ]; then
            if [ "$dryrun" = true ]; then
                echo "Selected: $entry" >&2
            else
                ${actions[$entry]}
            fi
            exit 0
        fi
        if [ "$selection" = "$(print_selection "${confirmationMessages[cancel]}")" ]; then
            exit 0
        fi
    done
    echo "Invalid selection: $selection" >&2
    exit 1
fi
