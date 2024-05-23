#!/usr/bin/env bash

time=`date +%Y_%m_%d-%T`
directory="`xdg-user-dir PICTURES`/Screenshots"
file="screenshot_from-${time}.png"
notify_cmd='dunstify -u low -h string:x-dunst-stack-tag:takescreenshot -i ~/.icons/Material-Black-Blueberry-Numix-FLAT/16/mimetypes/image-png.svg Screenshot'

# if the screenshots directory dont exists,
# create it
if [[ ! -d "${directory}" ]]; then
    mkdir -p "${directory}"
fi

# notify when a screenshot is taken
notify_shot () {
    ${notify_cmd} "Copied to the clipboard!"
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
}

# copy screenshot to clipboard
copy_shot () {
    cat "${directory}/$file" | xclip -i -selection clipboard -t image/png
}

# countdown
countdown () {
    for sec in `seq $1 -1 1`; do
        dunstify -a "timer" -t 1000 -h string:x-dunst-stack-tag:screenshottimer -i ~/.icons/Material-Black-Blueberry-Numix-FLAT/16/actions/clock.svg "Screenshoting in : $sec"
        sleep 1
    done
}

# screenshot all
shot_all () {
    gnome-screenshot -f "${directory}/${file}" && copy_shot
    notify_shot
}

# screenshot a specific window
shot_window () {
    gnome-screenshot -w -f "${directory}/${file}" && copy_shot
    notify_shot
}

# screenshot a selected area
shot_area () {
    gnome-screenshot -a -f "${directory}/${file}" && copy_shot
    notify_shot
}

usage () {
    cat << EOF
Usage: takeScreenshot [-h] [-d seconds] [-t]

  -h		Show this message.
  -d		Delay until the screenshot is taken.
  -t		Type of the screenshot. Suported are window, area and all.
EOF
}

while getopts 'hd:t:' opt; do
    case ${opt} in
        h)
            usage
            exit 0
            ;;
        d)
            DELAY="d"
            SECONDS=${OPTARG}
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

case ${TYPE} in
    "window")
        if [[ -n ${DELAY} ]]; then
            countdown ${SECONDS}
            sleep 1
        fi
        shot_window
        ;;
    "area")
        if [[ -n ${DELAY} ]]; then
            countdown ${SECONDS}
            sleep 1
        fi
        shot_area
        ;;
    "all")
        if [[ -n ${DELAY} ]]; then
            countdown ${SECONDS}
            sleep 1
        fi
        shot_all
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0
