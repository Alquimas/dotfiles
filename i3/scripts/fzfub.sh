#!/usr/bin/env bash

# Inspired by the script from Bread On Penguins
# You can find it here:
# https://github.com/BreadOnPenguins/scripts/blob/master/images-photos-wallpapers/fzfub

export PATH="${PATH}:${HOME}/.fzf/bin"

UB_PID_FILE=$(mktemp)
cleanup() {
    ueberzugpp cmd -s "${SOCKET}" -a exit
    rm "${UB_PID_FILE}"
}
trap cleanup HUP INT QUIT TERM EXIT

ueberzugpp layer \
    --no-stdin \
    --silent \
    --use-escape-codes \
    --pid-file "$UB_PID_FILE"

UB_PID=$(cat "${UB_PID_FILE}")

export SOCKET=/tmp/ueberzugpp-"$UB_PID".socket

DIRECTORY="$(xdg-user-dir PICTURES)/Screenshots"

LIST_CMD="fdfind \
    --type f \
    --absolute-path \
    --extension png \
    . ${DIRECTORY}"

export LIST_CMD

ILABEL="cliphist: press enter to copy"
LABEL="ctrl [ g - gimp | d - delete]"
FZFARGS="enter:execute(xclip -selection clipboard -t image/png {} && notify-send \"Copied to clipboard!\" {}),\
ctrl-g:become(setsid -f gimp {+} >/dev/null 2>&1 </dev/null),\
ctrl-d:execute(rm {+} && notify-send \"Deleted\" \"$(printf '%s ' {+})\")+reload(${LIST_CMD})"

sh -c "${LIST_CMD}" | \
fzf \
    -m \
    --bind "${FZFARGS}" \
    --style=full \
    --reverse \
    --preview-border \
    --delimiter '/' \
    --with-nth -1 \
    --preview-label "${LABEL}" \
    --input-label "${ILABEL}" \
    --preview="/home/alquimas/projects/stuff/ueberzugpp/build/ueberzugpp cmd \
               -s ${SOCKET} \
               -i fzfpreview \
               -a add \
               -x \$FZF_PREVIEW_LEFT \
               -y \$FZF_PREVIEW_TOP \
               --max-width \$FZF_PREVIEW_COLUMNS \
               --max-height \$FZF_PREVIEW_LINES \
               -f {}"

ueberzugpp cmd -s "$SOCKET" -a exit
