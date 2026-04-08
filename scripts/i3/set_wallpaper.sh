#!/bin/bash

WALLPAPER_DIR="${HOME}/.config/i3"

WALLPAPER_FILE=$(find -L "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)

if [ -n "${WALLPAPER_FILE}" ]; then

    feh --bg-fill "${WALLPAPER_FILE}"
else
    echo "No wallpaper found in ${WALLPAPER_DIR}"
fi
