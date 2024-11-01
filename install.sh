#!/usr/bin/env bash
# Based on the install script from https://github.com/dikiaap/dotfiles/blob/master/install.sh

blue='\e[1;34m'
red='\e[1;31m'
white='\e[0;37m'
dotfiles_repo_dir=$(pwd)
backup_dir="${HOME}/.dotfiles_backup"
dotfiles_home_dir=(bash/.bashrc bash/.bash_profile bash/.bash_aliases)
dotfiles_xdg_config_dir=(alacritty dunst gtk-3.0 i3 i3blocks nvim picom rofi tmux)

# Print usage message.
usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [-option]

Options:
    --help    Print this message
    -i        Install all config
    -r        Restore old config
EOF
}

install_dotfiles() {
    # Create backup
    if ! [ -f "$backup_dir/check-backup.txt" ]; then
        mkdir -p "${backup_dir}/.config"
        cd "${backup_dir}" || exit
        touch check-backup.txt

        # Create backup from home files inside ~/.dotfiles_backup
        for dots_home in "${dotfiles_home_dir[@]##*/}"
        do
            env cp -rfL "${HOME}/${dots_home}" "${backup_dir}" &> /dev/null
        done

        # Backup folders in .config than will be overwritten
        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"
        do
            env cp -rfL "${HOME}/.config/${dots_xdg_conf}" "${backup_dir}/.config" &> /dev/null
        done

        # Output.
        echo -e "${blue}Your config is backed up in ${backup_dir}\n" >&2
        echo -e "${red}Please do not delete check-backup.txt in .dotfiles_backup folder.${white}" >&2
        echo -e "It's used to backup and restore your old config.\n" >&2
    fi
}

install_dotfiles
