#!/usr/bin/env bash
# Based on the install script from 
# https://github.com/dikiaap/dotfiles/blob/master/install.sh

blue='\e[1;34m'
red='\e[1;31m'
white='\e[0;37m'
dotfiles_repo_dir=$(pwd)
backup_dir="${HOME}/.dotfiles_backup"
dotfiles_home_dir=(bash/.bashrc bash/.bash_profile bash/.bash_aliases)
dotfiles_xdg_config_dir=(alacritty dunst gtk-3.0 i3\
    i3blocks picom rofi tmux bash)

# Print usage message.
usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: ${program_name} [-option]

Options:
    --help    Print this message
    -i        Backup old config, then install a new one
    -r        Restore old config
EOF
}

backup_dotfiles() {
    # Create backup in the same format pattern from this dotfiles
    if ! [ -f "${backup_dir}/check-backup.txt" ]; then
        mkdir -p "${backup_dir}"
        cd "${backup_dir}" || exit
        touch check-backup.txt

        # Create backup from home files than will be overwritten
        for dots_home in "${dotfiles_home_dir[@]}"
        do
            home_file=${dots_home##*/}
            folder_file=${dots_home%/*}
            mkdir -p "${folder_file}"
            env cp -rfL "${HOME}/${dots_home}" "${backup_dir}/${folder_file}" \
                &> /dev/null
        done

        # Backup folders in .config than will be overwritten
        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"
        do
            env cp -rfL "${HOME}/.config/${dots_xdg_conf}" \
            "${backup_dir}" &> /dev/null
        done

        # Backup with git
        if [ -x "$(command -v git)" ]; then
            git init &> /dev/null
            git add -u &> /dev/null
            git add . &> /dev/null
            git commit -m "Backup on $(date '+%Y-%m-%d_%H:%M')" &> /dev/null
        fi

        # Output.
        echo -e "${blue}Your config is backed up in ${backup_dir}\n" >&2
        echo -e "${red}Please do not delete check-backup.txt in \
.dotfiles_backup folder.${white}" >&2
        echo -e "It's used to backup and restore your old config.\n" >&2
    fi
}

install_dotfiles() {
    # Create a backup
    backup_dotfiles

    # Install config file in HOME directory
    for dots_home in "${dotfiles_home_dir[@]}"
    do
        home_file="${dots_home##*/}"
        env rm -rf "${HOME}/${home_file}"
        env ln -fs "${dotfiles_repo_dir}/${dots_home}" "${HOME}/"
    done

    # Install config to ~/.config
    mkdir -p "${HOME}/.config"
    for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"
    do
        env rm -rf "${HOME}/.config/${dots_xdg_conf}"
        env ln -fs "${dotfiles_repo_dir}/${dots_xdg_conf}" \
            "${HOME}/.config/${dots_xdg_conf}"
    done

    echo -e "${blue}New dotfiles is installed!\n${white}" >&2
    echo "There may be some errors when Terminal is restarted." >&2
    echo "Please read carefully the error messages and make sure \
all packages are installed. See more info in README.md." >&2
    echo -e "If you want to restore your old config, you can use \
${red}./install.sh -r${white} command." >&2
}

uninstall_dotfiles() {
    if [ -f "${backup_dir}/check-backup.txt" ]; then
        for dots_home in "${dotfiles_home_dir[@]}"
        do
            home_file="${dots_home##*/}"
            env rm -rf "${HOME}/${home_file}"
            env cp -rf "${backup_dir}/${dots_home}" "${HOME}/" &> /dev/null
            env rm -rf "${backup_dir}/${dots_home}"
        done

        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"
        do
            env rm -rf "${HOME}/.config/${dots_xdg_conf}"
            env cp -rf "${backup_dir}/${dots_xdg_conf}" "${HOME}/.config" \
                &> /dev/null
            env rm -rf "${backup_dir}/${dots_xdg_conf}"
        done

        # Save old config in backup directory with Git.
        if [ -x "$(command -v git)" ]; then
            cd "$backup_dir" || exit
            git add -u &> /dev/null
            git add . &> /dev/null
            git commit -m "Restore original config on \
                $(date '+%Y-%m-%d %H:%M')" &> /dev/null
        fi

        echo -e "${blue}Your old config has been restored!\n${white}" >&2

        env rm "${backup_dir}/check-backup.txt"
    else
        echo -e "${red}You have not installed this dotfiles yet.${white}" >&2
        exit 1
    fi
}

main() {
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        -i)
            install_dotfiles
            ;;
        -r)
            uninstall_dotfiles
            ;;
        *)
            echo "Command not found" >&2
            exit 1
    esac
}

main "$@"
