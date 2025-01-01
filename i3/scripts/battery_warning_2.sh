#!/usr/bin/env bash

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

    STATUS=$(cat "${BATTERY_PATH}/BAT0/status")
    CAPACITY=$(cat "${BATTERY_PATH}/BAT0/capacity")

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

            notify-send "Full battery" "The battery is fully charged."

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
        sleep 90
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
        notify-send -u critical "Low Battery" "Battery lower than 20%. Find a charger."
        update_and_wait
        continue
    fi

    update_and_wait

done
