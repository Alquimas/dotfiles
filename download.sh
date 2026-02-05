#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

if [[ "$EUID" -eq 0 ]]; then
  echo "This script can't be executed as root user" >&2
  echo "Use: ./download.sh (without sudo)" >&2
  exit 1
fi

for cmd in sudo apt wget dpkg; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing required command: $cmd" >&2
    exit 1
  }
done

sudo -v

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Apt dependencies
sudo apt update
sudo apt install -y \
    brightnessctl \
    dunst \
    feh \
    git \
    i3-wm \
    i3blocks \
    libgtk-3-0 \
    maim \
    rofi \
    picom \
    redshift \
    tmux \
    thunar \
    xclip \
    curl \
    gcc \
    g++ \
    pkg-config \
    fontconfig \
    cmake \
    libfontconfig1-dev \
    lightdm \
    firefox-esr

wget -q --show-progress --https-only --secure-protocol=TLSv1_2 \
    -O "${TMP_DIR}/fastfetch.deb" \
    "https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb"

sudo dpkg -i "${TMP_DIR}/fastfetch.deb"

if [[ ! -d "$HOME/.fzf" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
  "${HOME}/.fzf/install" --all
fi

curl --proto '=https' --tlsv1.2 -sSf \
    https://sh.rustup.rs -o "${TMP_DIR}/rustup-init.sh"

chmod +x "${TMP_DIR}/rustup-init.sh"

"${TMP_DIR}/rustup-init.sh" -y

source "${HOME}/.cargo/env"

cargo install alacritty

cargo install starship --locked
