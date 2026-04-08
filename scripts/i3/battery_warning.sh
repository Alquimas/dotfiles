#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

SOUND="${HOME}/.config/scripts/i3/battery_warning.wav"

usage() {
    cat <<'EOF'
Usage: battery_warning.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(find notify-send paplay sleep)
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

update_and_wait() {
    LAST_STATUS=${STATUS}
    LAST_CAPACITY=${CAPACITY}
    sleep 30
}

main() {
    local battery_path="/sys/class/power_supply"
    local total_energy_now
    local total_energy_full
    local overall_status
    local status
    local now
    local full

    LAST_STATUS="Charging"
    LAST_CAPACITY="100"
    STATUS=""
    CAPACITY=""

    while true; do
        mapfile -t batteries < <(find -L "${battery_path}" -maxdepth 1 -type d -name "BAT*")
        total_energy_now=0
        total_energy_full=0
        overall_status="Unknown"

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

            (( total_energy_now += now ))
            (( total_energy_full += full ))

            case "${status}" in
                Charging) overall_status="Charging" ;;
                Full) [[ "${overall_status}" != "Charging" ]] && overall_status="Full" ;;
                Discharging)
                    [[ "${overall_status}" != "Charging" && "${overall_status}" != "Full" ]] \
                        && overall_status="Discharging"
                    ;;
            esac
        done

        if (( total_energy_full > 0 )); then
            CAPACITY=$(( total_energy_now * 100 / total_energy_full ))
        else
            CAPACITY=0
        fi

        STATUS="${overall_status}"

        if [[ ${STATUS} = "Charging" ]]; then
            update_and_wait
            continue
        elif [[ ${STATUS} = "Unknown" ]]; then
            if [[ ${LAST_STATUS} != "Unknown" ]]; then
                notify-send "No battery found" "No batteries were found."
            fi
            update_and_wait
            continue
        elif [[ ${STATUS} = "Full" ]]; then
            if [[ ${LAST_STATUS} != "Full" ]]; then
                notify-send "Full" "The battery is fully charged."
            fi
            update_and_wait
            continue
        elif [[ ${STATUS} = "Not charging" ]]; then
            if [[ ${LAST_STATUS} != "Not charging" ]]; then
                notify-send "Not charging" "The battery is connected to a power source, but is not charging."
            fi
            update_and_wait
            continue
        fi

        if [[ ${LAST_STATUS} = "Discharging" && ${LAST_CAPACITY} -le 5 ]]; then
            continue
        fi

        if [[ ${LAST_STATUS} = "Discharging" && ${LAST_CAPACITY} -le 20 ]]; then
            if [[ ${CAPACITY} -le 5 ]]; then
                paplay "${SOUND}" &
                notify-send -u critical "Critical Battery" "Battery lower than 5%, computer will shutdown soon."
            fi
            update_and_wait
            continue
        fi

        if [[ ${CAPACITY} -le 5 ]]; then
            paplay "${SOUND}" &
            notify-send -u critical "Critical Battery" "Battery lower than 5%, computer will shutdown soon."
            update_and_wait
            continue
        fi

        if [[ ${CAPACITY} -le 20 ]]; then
            paplay "${SOUND}" &
            notify-send -u normal "Low Battery" "Battery lower than 20%. Find a charger."
            update_and_wait
            continue
        fi

        update_and_wait
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
