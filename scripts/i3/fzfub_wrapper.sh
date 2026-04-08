#!/usr/bin/env bash

# A wrapper around fzfub.sh script
# Starts a alacritty terminal
# Set class name so i3 make it a floating window
# Make dimensions a little smaller
# Make backgroup opaque
# Run the script
"${HOME}/.cargo/bin/alacritty" \
    --class="Alacritty-float" \
    --option='window.dimensions.lines=18' \
    --option='window.opacity=1' \
    -e "${HOME}/.config/scripts/i3/fzfub.sh"
