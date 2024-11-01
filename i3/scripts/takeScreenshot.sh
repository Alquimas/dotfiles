#!/usr/bin/env bash

time=$(date +%Y_%m_%d-%T)
directory="$(xdg-user-dir PICTURES)/Screenshots"
file="screenshot_from-${time}.png"
notify_cmd='dunstify -a "popup" -h string:x-dunst-stack-tag:takescreenshot -i ~/.local/share/icons/Material-Black-Blueberry-Numix-FLAT/16/mimetypes/image-png.svg Screenshot'

# if the screenshots directory dont exists, create it
if [[ ! -d "${directory}" ]]; then
    mkdir -p "${directory}"
fi

# notify when a screenshot is taken
notify_shot () {
    eval "${notify_cmd} Copied\ to\ the\ clipboard!"
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
}

# copy screenshot to clipboard
copy_shot () {
    tee "${file}" | xclip -selection clipboard -t image/png
}

# screenshot all
shot_all () {
    cd "${directory}" && maim -u -f png | copy_shot && notify_shot
}

# screenshot a specific window
shot_window () {
    cd "${directory}" && maim -u -f png -i "$(xdotool getactivewindow)" \
    | copy_shot && notify_shot
}

# screenshot a selected area
shot_area () {
    cd "${directory}" && maim -u -f png -s -b 1.5 -c 0.3,0.50,0.85,0.25 -l \
    | copy_shot && notify_shot
}

usage () {
    cat << EOF
Usage: takeScreenshot [-h] [-d seconds] [-t]

  -h		Show this message.
  -t		Type of the screenshot. Suported are window, area and all.
EOF
}

while getopts 'ht:' opt; do
    case ${opt} in
        h)
            usage
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

case ${TYPE} in
    "window")
        shot_window
        ;;
    "area")
        shot_area
        ;;
    "all")
        shot_all
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0
