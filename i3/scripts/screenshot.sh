#!/usr/bin/env bash

while getopts 'cwapd:' opt; do
    case ${opt} in
        c)
            TO_CLIPBOARD="-c"
            ;;
        w)
            WINDOW="-w"
            ;;
        a)
            AREA="-a"
            ;;
        p)
            POINTER="-p"
            ;;
        d)
            DELAY="-d"
            SECONDS=${OPTARG}
            ;;
        \?)
            echo "Usage $(basename $0) [-c] [-w] [-a] [-p] [-d seconds]"
            exit 1
        ;;
    esac
done

IMAGE=${HOME}/Pictures/screenshots/screenshot_from_$(date +%Y_%m_%d-%T).png

if [[ -n ${TO_CLIPBOARD} ]]; then
    TO_CLIPBOARD="cat ${IMAGE} | xclip -i -selection clipboard -target image/png"
else
    TO_CLIPBOARD=""
fi

if [[ -n ${DELAY} ]]; then
    gnome-screenshot \
    ${WINDOW} \
    ${AREA} \
    ${POINTER} \
    ${DELAY} \
    ${SECONDS} \
    -f ${IMAGE} && \
    eval ${TO_CLIPBOARD}
else
    gnome-screenshot \
    ${WINDOW} \
    ${AREA} \
    ${POINTER} \
    -f ${IMAGE} && \
    eval ${TO_CLIPBOARD}
fi

