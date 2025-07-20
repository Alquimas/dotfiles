# Dotfiles

## Here are my dotfiles. That's it.

![Nvim example](images/nvim.png)

<p align="center">
    <b>Screenshots</b><br>
    <a href="images/rofi.png">Rofi</a>&nbsp;&nbsp;&nbsp;
    <a href="images/thunar.png">Thunar</a>&nbsp;&nbsp;&nbsp;
    <a href="images/tmux.png">Tmux</a>
</p>

## About this repository

While I'd love to try to make this work out of the box, that's not my main goal. I see this repository as a project to play around with Linux a bit and get a better understanding of the system. Feel free to use anything available here, and if you encounter any issues, feedback is welcome.

## Installation

The `install.sh` script simply creates the symlinks that point to the files inside the repository. To do this, just run `./install.sh` at the root of the repository, and, if necessary, run `chmod +x install.sh` to give the script executable permission.
It also creates a simple backup of your current configuration, and allows you to restore it if something goes wrong. Furthermore, any dependencies must be installed manually, which are described later.

## Dependencies

I use Debian 12, and I installed most of the dependencies through apt. Below are the main programs I use and how I downloaded them:

| Item          | Source | Version   |
|---------------|--------|-----------|
| alacritty     | Cargo  | 0.14.0    |
| brightnessctl | Apt    | 0.5       |
| dunst         | Apt    | 1.9.0     |
| fastfetch     | Github | 2.33.0    |
| feh           | Apt    | 3.9.1     |
| fzf           | Github | 0.57.0    |
| git           | Apt    | 2.39.5    |
| gtk3          | Apt    | 3.24.38-2 |
| i3-wm         | Apt    | 4.22-2    |
| i3blocks      | Apt    | 1.4-4     |
| maim          | Apt    | 5.7.4-2   |
| rofi          | Apt    | 1.7.3     |
| picom         | Apt    | 9.1-1     |
| redshift      | Apt    | 1.21.1    |
| starship      | Cargo  | 1.21.1    |
| tmux          | Apt    | 3.3a      |
| thunar        | Apt    | 4.18.4    |
| xclip         | Apt    | 0.13      |

In addition, there are dependencies for GTK and for a font. They are

    - `Catppuccin-Mocha-Standard-Sky-Dark` theme for GTK.
    - `Material-Black-Blueberry-Numix-FLAT` icon theme for GTK.
    - `Bibata-Modern-Classic` cursor theme for GTK.
    - `VCROSDMono` font. A patched version of the [VCROSD](https://www.dafont.com/font-comment.php?file=vcr_osd_mono) font.

All of these are inside the `resources` folder.

## APT dependencies

If you are using Debian or one of its derivatives, you can install the APT dependencies that I mentioned here with the following command:

```
sudo apt install brightnessctl dunst feh git i3-wm i3blocks libgtk-3-0 maim rofi picom redshift tmux thunar xclip
```

And if you are going to use Cargo, you may need to install one of the following packages:

```
sudo apt install curl gcc g++ pkg-config fontconfig cmake
```
