#!/usr/bin/env bash

if [[ "$EUID" -eq 0 ]]; then
  echo "This script can't be executed as root user"
  echo "Use: ./install.sh (without sudo)"
  exit 1
fi

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
    lightdm

mkdir -p "${HOME}/install_tmp"

# Install fastfetch
wget "https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb --directory-prefix=${HOME}/install_tmp"

sudo dpkg -i "${HOME}/install_tmp/fastfetch-linux-amd64.deb"

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "${HOME}/install_tmp/rustup-init.sh"

chmod +x "${HOME}/install_tmp/rustup-init.sh"

"${HOME}/install_tmp/rustup-init.sh" -y

. "$HOME/.cargo/env"

# Install alacritty
cargo install alacritty

# Install startship
cargo install starship --locked
