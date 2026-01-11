#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

layout=$(setxkbmap -query | awk '/layout:/ {print $2}')
variant=$(setxkbmap -query | awk '/variant:/ {print $2}')

caps_on=$(xset q | grep -q "Caps Lock:\s*on" && echo 1 || echo 0)

if [[ -n "${variant}" ]]; then
  kb="${layout}(${variant})"
else
  kb="${layout}"
fi

if [[ "${caps_on}" -eq 1 ]]; then
  echo "${kb^^}"
else
  echo "$kb"
fi
