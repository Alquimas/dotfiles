#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

if [[ "$EUID" -eq 0 ]]; then
  echo "This script can't be executed as root user" >&2
  echo "Use: ./scripts/bootstrap/download.sh (without sudo)" >&2
  exit 1
fi

for cmd in sudo wget curl git; do
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

if command -v apt-get >/dev/null 2>&1; then
  echo "--> Debian-based system detected."

  sudo apt update
  sudo apt install -y \
    brightnessctl dunst feh git i3-wm i3blocks libgtk-3-0 maim \
    rofi picom redshift tmux thunar xclip curl gcc g++ pkg-config \
    fontconfig cmake libfontconfig1-dev lightdm firefox-esr fzf

  wget -q --show-progress --https-only --secure-protocol=TLSv1_2 \
    -O "${TMP_DIR}/fastfetch.deb" \
    "https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb"
  sudo dpkg -i "${TMP_DIR}/fastfetch.deb"

elif command -v pacman >/dev/null 2>&1; then
  echo "--> Arch-based system detected."

  sudo pacman -Sy --noconfirm
  sudo pacman -S --noconfirm \
    brightnessctl dunst feh git i3-wm i3blocks gtk3 maim \
    rofi picom redshift tmux thunar xclip curl gcc pkgconf \
    fontconfig cmake lightdm firefox fastfetch fzf ueberzugpp \
    gimp xdg-user-dirs xorg-xset xdotool sysstat tree-sitter-cli \
    unzip pulseaudio network-manager-applet
else
  echo "Error: Neither apt nor pacman found. Unsupported distribution." >&2
  exit 1
fi

curl --proto '=https' --tlsv1.2 -sSf \
    https://sh.rustup.rs -o "${TMP_DIR}/rustup-init.sh"

chmod +x "${TMP_DIR}/rustup-init.sh"
"${TMP_DIR}/rustup-init.sh" -y

if [ -f "${HOME}/.cargo/env" ]; then
  source "${HOME}/.cargo/env"
fi

cargo install alacritty
cargo install starship --locked
cargo install fd-find

sudo usermod -aG audio $(whoami)
sudo usermod -aG video $(whoami)
