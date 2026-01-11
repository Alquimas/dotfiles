#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

LAST_STATUS="Charging"
LAST_CAPACITY="100"
STATUS=""
CAPACITY=""
BATTERY_PATH="/sys/class/power_supply"
SOUND="${HOME}/.config/i3/scripts/battery_warning.wav"

update_and_wait() {
    LAST_STATUS=${STATUS}
    LAST_CAPACITY=${CAPACITY}
    sleep 30
}

while true; do

    BATTERIES=($(find -L "${BATTERY_PATH}" -maxdepth 1 -type d -name "BAT*"))
    total_energy_now=0
    total_energy_full=0
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
        (( total_energy_now += now ))
        (( total_energy_full += full ))

        case "$status" in
            "Charging") overall_status="Charging" ;;
            "Full") [[ "$overall_status" != "Charging" ]] && overall_status="Full" ;;
            "Discharging") [[ "$overall_status" != "Charging" && "$overall_status" != "Full" ]] && overall_status="Discharging" ;;
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
    # from here below, ${STATUS} = Discharging

    # The notification about 5% was already poped
    # There's no more notifications to pop without changing the state
    if [[ ${LAST_STATUS} = "Discharging" && ${LAST_CAPACITY} -le 5 ]]; then
        continue
    fi

    # The notification about 20% was already poped
    # Now we just wait until the battery reach 5%
    # to pop another notification
    if [[ ${LAST_STATUS} = "Discharging" && ${LAST_CAPACITY} -le 20 ]]; then

        if [[ ${CAPACITY} -le 5 ]]; then

            paplay "${SOUND}" &
            notify-send -u critical "Critical Battery" "Battery lower than 5%, computer will shutdown soon."

        fi
        update_and_wait
        continue

    fi

    # If the battery already starts at less than 5%
    # We just play the last notification
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
