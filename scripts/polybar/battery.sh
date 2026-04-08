#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

BATTERY_PATH="/sys/class/power_supply"

# Icons (Font Awesome / Nerd Font)
ICON_CHARGING=" "
ICON_FULL=""
ICON_DISCHARGING="󰁹"
ICON_UNKNOWN=""

BATTERIES=($(find -L "${BATTERY_PATH}" -maxdepth 1 -type d -name "BAT*"))

if [[ ${#BATTERIES[@]} -eq 0 ]]; then
    echo "${ICON_UNKNOWN} N/A"
    exit 0
fi

total_now=0
total_full=0
overall_status="Unknown"

for BAT in "${BATTERIES[@]}"; do
    status=$(<"${BAT}/status")

    if [[ -f "${BAT}/energy_now" && -f "${BAT}/energy_full" ]]; then
        now=$(<"${BAT}/energy_now")
        full=$(<"${BAT}/energy_full")
    elif [[ -f "${BAT}/charge_now" && -f "${BAT}/charge_full" ]]; then
        now=$(<"${BAT}/charge_now")
        full=$(<"${BAT}/charge_full")
    else
        now=$(<"${BAT}/capacity")
        full=100
    fi

    (( total_now += now ))
    (( total_full += full ))

    case "$status" in
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
else
    percent=0
fi

case "${overall_status}" in
    Charging)
        icon="${ICON_CHARGING}"
        ;;
    Full)
        icon="${ICON_FULL}"
        ;;
    Discharging)
        icon="${ICON_DISCHARGING}"
        ;;
    *)
        icon="${ICON_UNKNOWN}"
        ;;
esac

echo "${icon} ${percent}%"
