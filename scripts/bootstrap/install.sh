#!/usr/bin/env bash
# Based on the install script from
# https://github.com/dikiaap/dotfiles/blob/master/install.sh

blue='\e[1;34m'
red='\e[1;31m'
white='\e[0;37m'
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dotfiles_repo_dir=$(cd "${script_dir}/../.." && pwd)
dotfiles_final_dir="${HOME}/.dotfiles"
backup_dir="${HOME}/.dotfiles_backup"
dotfiles_home_dir=(bash/.bashrc bash/.bash_profile bash/.bash_aliases xorg/.Xresources)
dotfiles_xdg_config_dir=(alacritty dunst gtk-3.0 i3 i3blocks picom polybar rofi scripts tmux bash)

usage() {
    local program_name=${0##*/}
    cat <<EOF
Usage: ${program_name} [-h] [-e] <-i|-r>

Options:
    -h    Print this message
    -e    Check script dependencies and exit
    -i    Backup old config, then install a new one
    -r    Restore old config
EOF
}

check_dependencies() {
    local cmds=(dirname env cp tar ln rm mkdir git touch date)
    local missing_cmds=()

    for cmd in "${cmds[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_cmds+=("$cmd")
        fi
    done

    if (( ${#missing_cmds[@]} > 0 )); then
        echo "Error: The following dependencies are missing:" >&2
        printf '   - %s\n' "${missing_cmds[@]}" >&2
        exit 1
    fi

    echo "Success: All dependencies (${#cmds[@]}) are met."
}

require_non_root() {
    if [[ "$EUID" -eq 0 ]]; then
        echo "This script can't be executed as root user" >&2
        echo "Use: ./scripts/bootstrap/install.sh (without sudo)" >&2
        exit 1
    fi
}

backup_dotfiles() {
    if ! [ -f "${backup_dir}/check-backup.txt" ]; then
        mkdir -p "${backup_dir}"
        cd "${backup_dir}" || exit
        touch check-backup.txt

        for dots_home in "${dotfiles_home_dir[@]}"; do
            local home_file=${dots_home##*/}
            local folder_file=${dots_home%/*}
            mkdir -p "${folder_file}"
            env cp -rfL "${HOME}/${dots_home}" "${backup_dir}/${folder_file}" &> /dev/null
        done

        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"; do
            env cp -rfL "${HOME}/.config/${dots_xdg_conf}" "${backup_dir}" &> /dev/null
        done

        git init &> /dev/null
        git add -u &> /dev/null
        git add . &> /dev/null
        git commit -m "Backup on $(date '+%Y-%m-%d_%H:%M')" &> /dev/null

        echo -e "${blue}Your config is backed up in ${backup_dir}\n" >&2
        echo -e "${red}Please do not delete check-backup.txt in .dotfiles_backup folder.${white}" >&2
        echo -e "It's used to backup and restore your old config.\n" >&2
    fi
}

move_dotfiles() {
    if [ "${dotfiles_repo_dir}" != "${dotfiles_final_dir}" ]; then
        echo "Dotfiles repository detected at ${dotfiles_repo_dir}."
        echo "The generated symlinks will point there."
        echo "If you want the canonical location, move the repository to ${dotfiles_final_dir} before reinstalling."
    fi
}

install_dotfiles() {
    require_non_root
    backup_dotfiles

    for dots_home in "${dotfiles_home_dir[@]}"; do
        local home_file="${dots_home##*/}"
        env rm -rf "${HOME}/${home_file}"
        env ln -fs "${dotfiles_repo_dir}/${dots_home}" "${HOME}/"
    done

    mkdir -p "${HOME}/.config"
    for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"; do
        env rm -rf "${HOME}/.config/${dots_xdg_conf}"
        env ln -fs "${dotfiles_repo_dir}/${dots_xdg_conf}" "${HOME}/.config/${dots_xdg_conf}"
    done

    move_dotfiles

    echo -e "${blue}New dotfiles is installed!\n${white}" >&2
    echo "There may be some errors when Terminal is restarted." >&2
    echo "Please read carefully the error messages and make sure all packages are installed. See more info in README.md." >&2
    echo -e "If you want to restore your old config, you can use ${red}./scripts/bootstrap/install.sh -r${white} command." >&2
}

uninstall_dotfiles() {
    require_non_root

    if [ -f "${backup_dir}/check-backup.txt" ]; then
        for dots_home in "${dotfiles_home_dir[@]}"; do
            local home_file="${dots_home##*/}"
            env rm -rf "${HOME}/${home_file}"
            env cp -rf "${backup_dir}/${dots_home}" "${HOME}/" &> /dev/null
            env rm -rf "${backup_dir}/${dots_home}"
        done

        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"; do
            env rm -rf "${HOME}/.config/${dots_xdg_conf}"
            env cp -rf "${backup_dir}/${dots_xdg_conf}" "${HOME}/.config" &> /dev/null
            env rm -rf "${backup_dir}/${dots_xdg_conf}"
        done

        cd "${backup_dir}" || exit
        git add -u &> /dev/null
        git add . &> /dev/null
        git commit -m "Restore original config on $(date '+%Y-%m-%d %H:%M')" &> /dev/null

        echo -e "${blue}Your old config has been restored!\n${white}" >&2

        env rm "${backup_dir}/check-backup.txt"
    else
        echo -e "${red}You have not installed this dotfiles yet.${white}" >&2
        exit 1
    fi
}

install_resources() {
    mkdir -p '/tmp/temp_resources'
    cp "${dotfiles_repo_dir}/resources/resources.tar.gz" '/tmp/temp_resources'
    tar -xzf '/tmp/temp_resources/resources.tar.gz' -C '/tmp/temp_resources'

    mkdir -p "${HOME}/.local/share/fonts"
    mkdir -p "${HOME}/.local/share/icons"
    mkdir -p "${HOME}/.local/share/themes"

    cp -r "/tmp/temp_resources/fonts/." "${HOME}/.local/share/fonts"
    cp -r "/tmp/temp_resources/icons/." "${HOME}/.local/share/icons"
    cp -r "/tmp/temp_resources/themes/." "${HOME}/.local/share/themes"

    mkdir -p "${HOME}/.fonts"
    mkdir -p "${HOME}/.icons"
    mkdir -p "${HOME}/.themes"

    cp -r "/tmp/temp_resources/fonts/." "${HOME}/.fonts"
    cp -r "/tmp/temp_resources/icons/." "${HOME}/.icons"
    cp -r "/tmp/temp_resources/themes/." "${HOME}/.themes"

    rm -r '/tmp/temp_resources'
    echo "Installed the resources!"
    echo "They are in the folders fonts, icons and themes under ~/.local/share and .fonts, .icons and .themes under ~."
}

main() {
    local action=""

    if [[ "${1-}" == "--help" && $# -eq 1 ]]; then
        usage
        exit 0
    fi

    while getopts ':heir' opt; do
        case "${opt}" in
            h)
                usage
                exit 0
                ;;
            e)
                check_dependencies
                exit 0
                ;;
            i|r)
                if [[ -n "${action}" ]]; then
                    usage
                    exit 1
                fi
                action="${opt}"
                ;;
            \?)
                usage
                exit 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if (( $# > 0 )) || [[ -z "${action}" ]]; then
        usage
        exit 1
    fi

    case "${action}" in
        i)
            install_dotfiles
            install_resources
            ;;
        r)
            uninstall_dotfiles
            ;;
    esac
}

main "$@"
