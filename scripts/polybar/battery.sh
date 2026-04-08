#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: battery.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(find)
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
    local battery_path="/sys/class/power_supply"
    local icon_charging=" "
    local icon_full=""
    local icon_discharging="󰁹"
    local icon_unknown=""
    local total_now=0
    local total_full=0
    local overall_status="Unknown"
    local percent=0
    local icon
    local status
    local now
    local full

    mapfile -t batteries < <(find -L "${battery_path}" -maxdepth 1 -type d -name "BAT*")

    if (( ${#batteries[@]} == 0 )); then
        echo "${icon_unknown} N/A"
        exit 0
    fi

    for battery in "${batteries[@]}"; do
        status=$(<"${battery}/status")

        if [[ -f "${battery}/energy_now" && -f "${battery}/energy_full" ]]; then
            now=$(<"${battery}/energy_now")
            full=$(<"${battery}/energy_full")
        elif [[ -f "${battery}/charge_now" && -f "${battery}/charge_full" ]]; then
            now=$(<"${battery}/charge_now")
            full=$(<"${battery}/charge_full")
        else
            now=$(<"${battery}/capacity")
            full=100
        fi

        (( total_now += now ))
        (( total_full += full ))

        case "${status}" in
            Charging) overall_status="Charging" ;;
            Full) [[ "${overall_status}" != "Charging" ]] && overall_status="Full" ;;
            Discharging)
                [[ "${overall_status}" != "Charging" && "${overall_status}" != "Full" ]] \
                    && overall_status="Discharging"
                ;;
        esac
    done

    if (( total_full > 0 )); then
        percent=$(( total_now * 100 / total_full ))
    fi

    case "${overall_status}" in
        Charging) icon="${icon_charging}" ;;
        Full) icon="${icon_full}" ;;
        Discharging) icon="${icon_discharging}" ;;
        *) icon="${icon_unknown}" ;;
    esac

    echo "${icon} ${percent}%"
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
