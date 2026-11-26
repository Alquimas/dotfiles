#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

if [[ "$EUID" -eq 0 ]]; then
  echo "This script can't be executed as root user" >&2
  echo "Use: ./scripts/bootstrap/download.sh (without sudo)" >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Error: Cannot identify the distribution. This script supports Artix Linux only." >&2
  exit 1
fi

. /etc/os-release
if [[ "${ID:-}" != artix ]]; then
  echo "Error: This script supports Artix Linux only." >&2
  exit 1
fi

if [[ "$(readlink -f /sbin/init 2>/dev/null)" != */openrc-init ]] ||
   ! rc-status --runlevel >/dev/null 2>&1; then
  echo "Error: This script requires Artix Linux running OpenRC." >&2
  exit 1
fi

for cmd in sudo pacman curl git; do
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

echo "--> Artix Linux detected."

sudo pacman -Syu --needed --noconfirm \
  brightnessctl dunst elogind elogind-openrc feh git i3-wm i3blocks \
  inotify-tools libnotify \
  lightdm lightdm-gtk-greeter lightdm-openrc maim \
  network-manager-applet networkmanager networkmanager-openrc picom polybar \
  polkit procps-ng psmisc rofi sysstat tmux thunar xclip xdotool \
  xorg-server xorg-setxkbmap xorg-xset \
  curl gcc pkgconf fontconfig cmake libx11 libxcb libxcursor gtk3 \
  firefox fastfetch fzf ueberzugpp gimp xdg-user-dirs \
  tree-sitter-cli unzip \
  pipewire pipewire-audio pipewire-pulse pipewire-alsa wireplumber \
  pipewire-openrc pipewire-pulse-openrc wireplumber-openrc

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
cargo install --git https://github.com/Alquimas/xcolor.git --branch master

sudo usermod -aG video "$(whoami)"
