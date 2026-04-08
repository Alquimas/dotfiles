#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: verify_dependencies.sh [-h]

  -h    Show this message.
EOF
}

main() {
    local script_dir
    local checked=0
    local failed=0

    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

    while IFS= read -r script; do
        printf 'Checking %s\n' "${script#"${script_dir}"/}"
        checked=$((checked + 1))

        if "${script}" -e; then
            printf 'OK: %s\n\n' "${script#"${script_dir}"/}"
        else
            printf 'FAIL: %s\n\n' "${script#"${script_dir}"/}" >&2
            failed=$((failed + 1))
        fi
    done < <(
        find "${script_dir}" -type f -name '*.sh' \
            ! -path "${script_dir}/bootstrap/download.sh" \
            ! -path "${script_dir}/verify_dependencies.sh" \
            | sort
    )

    printf 'Checked: %d\n' "${checked}"
    printf 'Failures: %d\n' "${failed}"

    if (( failed > 0 )); then
        exit 1
    fi
}

while getopts ':h' opt; do
    case "${opt}" in
        h)
            usage
            exit 0
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if (( $# > 0 )); then
    usage
    exit 1
fi

main
