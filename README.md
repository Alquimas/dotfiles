## Dotfiles

Here are my dotfiles. That's it.

## About this repository

While I'd love to try to make this work out of the box, that's not my main goal. I see this repository as a project to play around with Linux a bit and get a better understanding of the system. Feel free to use anything available here, and if you encounter any issues, feedback is welcome.

## Installation

The `install.sh` script simply creates the symlinks that point to the files inside the repository. To do this, just run `./install.sh` at the root of the repository, and, if necessary, run `chmod +x install.sh` to give the script executable permission.
It also creates a simple backup of your current configuration, and allows you to restore it if something goes wrong. Furthermore, any dependencies must be installed manually, which are described later.

## Dependencies

I use Debian 12, and I installed most of the dependencies through apt. Below are the main programs I use and how I downloaded them:

| Item   | Source | Version |
|--------|--------|---------|
| alacritty | Cargo | 0.13.2 |
| dunst | Apt | 1.9.0 |
| fastfetch | Github | 2.12.0 |
| feh | Apt | 3.9.1 |
| fzf | Github | 0.54.3 |
| git | Apt | 2.39.5 |
| gtk 3-0 | Apt | 3.24.38-2 |
| i3-wm  | Apt    | 4.22-2  |
| i3blocks | Apt  | 1.4-4   |
| maim | Apt | 5.7.4 |
| rofi | Apt | 1.7.3 |
| picom | Apt | 9.1-1 |
| redshift | Apt | 1.12 |
| starship | Github | 1.18.2 |
| tee | Apt | 9.1 |
| tmux | Apt | 3.3a-3 |
| thunar | Apt | 4.18.4 |
| xclip | Apt | 0.13.0 |

I also use the [Catppuccin](https://github.com/catppuccin/) in most programs that have it. In addition, there are dependencies for GTK and for a font. They are

    - `Catppuccin-Mocha-Standard-Sky-Dark` theme for GTK.
    - `Material-Black-Blueberry-Numix-FLAT` icon theme for GTK.
    - `Bibata-Modern-Classic` cursor theme for GTK.
    - `ComicShannsMonoNerdFont` font. I use this font in all applications that allow custom fonts.

You can download and use the ones that work best for you, but you will need to manually change them in the configuration files.
