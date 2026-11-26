#!/usr/bin/env bash
# Based on the install script from
# https://github.com/dikiaap/dotfiles/blob/master/install.sh
set -Eeuo pipefail

blue='\e[1;34m'
red='\e[1;31m'
white='\e[0;37m'
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dotfiles_repo_dir=$(cd "${script_dir}/../.." && pwd)
dotfiles_final_dir="${HOME}/.dotfiles"
backup_dir="${HOME}/.dotfiles_backup"
backup_marker="${backup_dir}/check-backup.txt"
backup_manifest="${backup_dir}/original-paths.txt"
dotfiles_home_dir=(bash/.bashrc bash/.bash_profile bash/.bash_aliases xorg/.Xresources)
dotfiles_xdg_config_dir=(alacritty dunst gtk-3.0 i3 picom polybar rofi scripts tmux bash)

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
    local cmds=(dirname cp tar ln rm mkdir mktemp mv readlink touch cat)
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

path_exists() {
    [[ -e "$1" || -L "$1" ]]
}

is_installed_link() {
    [[ -L "$1" && "$(readlink -- "$1")" == "$2" ]]
}

validate_sources() {
    local relative
    local name

    for relative in "${dotfiles_home_dir[@]}"; do
        if [[ ! -f "${dotfiles_repo_dir}/${relative}" ]]; then
            echo "Missing dotfile source: ${dotfiles_repo_dir}/${relative}" >&2
            return 1
        fi
    done

    for name in "${dotfiles_xdg_config_dir[@]}"; do
        if [[ ! -d "${dotfiles_repo_dir}/${name}" ]]; then
            echo "Missing config source: ${dotfiles_repo_dir}/${name}" >&2
            return 1
        fi
    done

    if [[ ! -f "${dotfiles_repo_dir}/resources/resources.tar.gz" ]]; then
        echo "Missing resources archive." >&2
        return 1
    fi
}

validate_installed_links() {
    local relative
    local name
    local destination
    local source

    for relative in "${dotfiles_home_dir[@]}"; do
        destination="${HOME}/${relative##*/}"
        source="${dotfiles_repo_dir}/${relative}"
        if path_exists "$destination" && ! is_installed_link "$destination" "$source"; then
            echo "Refusing to replace changed config: ${destination}" >&2
            return 1
        fi
    done

    for name in "${dotfiles_xdg_config_dir[@]}"; do
        destination="${HOME}/.config/${name}"
        source="${dotfiles_repo_dir}/${name}"
        if path_exists "$destination" && ! is_installed_link "$destination" "$source"; then
            echo "Refusing to replace changed config: ${destination}" >&2
            return 1
        fi
    done
}

backup_dotfiles() {
    local relative
    local name
    local destination

    if [[ -f "${backup_marker}" ]]; then
        validate_installed_links
        return
    fi

    if path_exists "${backup_dir}"; then
        echo "Refusing to overwrite existing backup directory: ${backup_dir}" >&2
        return 1
    fi

    mkdir -p "${backup_dir}"
    : > "${backup_manifest}"

    for relative in "${dotfiles_home_dir[@]}"; do
        destination="${HOME}/${relative##*/}"
        if path_exists "$destination"; then
            mkdir -p "${backup_dir}/${relative%/*}"
            cp -a -- "$destination" "${backup_dir}/${relative}"
            printf '%s\n' "$relative" >> "${backup_manifest}"
        fi
    done

    for name in "${dotfiles_xdg_config_dir[@]}"; do
        relative=".config/${name}"
        destination="${HOME}/${relative}"
        if path_exists "$destination"; then
            mkdir -p "${backup_dir}/.config"
            cp -a -- "$destination" "${backup_dir}/${relative}"
            printf '%s\n' "$relative" >> "${backup_manifest}"
        fi
    done

    touch "${backup_marker}"
    echo -e "${blue}Your config is backed up in ${backup_dir}\n${white}" >&2
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
    validate_sources
    backup_dotfiles

    local relative
    local name
    local destination
    local source

    for relative in "${dotfiles_home_dir[@]}"; do
        destination="${HOME}/${relative##*/}"
        source="${dotfiles_repo_dir}/${relative}"
        if ! is_installed_link "$destination" "$source"; then
            if path_exists "$destination"; then
                rm -rf -- "$destination"
            fi
            ln -s -- "$source" "$destination"
        fi
    done

    mkdir -p "${HOME}/.config"
    for name in "${dotfiles_xdg_config_dir[@]}"; do
        destination="${HOME}/.config/${name}"
        source="${dotfiles_repo_dir}/${name}"
        if ! is_installed_link "$destination" "$source"; then
            if path_exists "$destination"; then
                rm -rf -- "$destination"
            fi
            ln -s -- "$source" "$destination"
        fi
    done

    move_dotfiles
}

uninstall_dotfiles() {
    require_non_root

    if [[ ! -f "${backup_marker}" ]]; then
        echo -e "${red}You have not installed this dotfiles yet.${white}" >&2
        return 1
    fi

    if [[ ! -f "${backup_manifest}" ]]; then
        echo "This backup predates the verified manifest. Restore it manually; the old installer may have missed home files." >&2
        return 1
    fi

    validate_installed_links

    if path_exists "${HOME}/.config" && [[ ! -d "${HOME}/.config" ]]; then
        echo "Cannot restore configs: ${HOME}/.config is not a directory." >&2
        return 1
    fi

    local relative
    local name
    local destination
    local archive_dir
    declare -A original_paths=()

    while IFS= read -r relative; do
        original_paths["$relative"]=1
    done < "${backup_manifest}"

    for relative in "${dotfiles_home_dir[@]}"; do
        if [[ -v original_paths[$relative] ]] && ! path_exists "${backup_dir}/${relative}"; then
            echo "Missing backup copy: ${backup_dir}/${relative}" >&2
            return 1
        fi
    done
    for name in "${dotfiles_xdg_config_dir[@]}"; do
        relative=".config/${name}"
        if [[ -v original_paths[$relative] ]] && ! path_exists "${backup_dir}/${relative}"; then
            echo "Missing backup copy: ${backup_dir}/${relative}" >&2
            return 1
        fi
    done

    for relative in "${dotfiles_home_dir[@]}"; do
        destination="${HOME}/${relative##*/}"
        if path_exists "$destination"; then
            rm -- "$destination"
        fi
        if [[ -v original_paths[$relative] ]]; then
            cp -a -- "${backup_dir}/${relative}" "$destination"
        fi
    done

    mkdir -p "${HOME}/.config"
    for name in "${dotfiles_xdg_config_dir[@]}"; do
        relative=".config/${name}"
        destination="${HOME}/${relative}"
        if path_exists "$destination"; then
            rm -- "$destination"
        fi
        if [[ -v original_paths[$relative] ]]; then
            cp -a -- "${backup_dir}/${relative}" "$destination"
        fi
    done

    archive_dir=$(mktemp -d "${HOME}/.dotfiles_backup.restored.XXXXXXXX")
    mv -- "${backup_dir}" "${archive_dir}/backup"
    rm -- "${archive_dir}/backup/check-backup.txt"

    echo -e "${blue}Your old config has been restored!\n${white}" >&2
    echo "The backup remains in ${archive_dir}/backup."
}

install_resources() (
    local temp_resources
    temp_resources=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-resources.XXXXXXXX")
    trap 'rm -rf -- "$temp_resources"' EXIT
    tar -xzf "${dotfiles_repo_dir}/resources/resources.tar.gz" -C "$temp_resources"

    mkdir -p "${HOME}/.local/share/fonts"
    mkdir -p "${HOME}/.local/share/icons"
    mkdir -p "${HOME}/.local/share/themes"

    cp -a "${temp_resources}/fonts/." "${HOME}/.local/share/fonts"
    cp -a "${temp_resources}/icons/." "${HOME}/.local/share/icons"
    cp -a "${temp_resources}/themes/." "${HOME}/.local/share/themes"

    mkdir -p "${HOME}/.fonts"
    mkdir -p "${HOME}/.icons"
    mkdir -p "${HOME}/.themes"

    cp -a "${temp_resources}/fonts/." "${HOME}/.fonts"
    cp -a "${temp_resources}/icons/." "${HOME}/.icons"
    cp -a "${temp_resources}/themes/." "${HOME}/.themes"

    echo "Installed the resources!"
    echo "They are in the folders fonts, icons and themes under ~/.local/share and .fonts, .icons and .themes under ~."
)

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
            echo -e "${blue}New dotfiles is installed!\n${white}" >&2
            echo "There may be some errors when Terminal is restarted." >&2
            echo "Please read carefully the error messages and make sure all packages are installed. See more info in README.md." >&2
            echo -e "If you want to restore your old config, you can use ${red}./scripts/bootstrap/install.sh -r${white} command." >&2
            ;;
        r)
            uninstall_dotfiles
            ;;
    esac
}

main "$@"
