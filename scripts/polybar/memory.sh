#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
LANG=C

usage() {
    cat <<'EOF'
Usage: memory.sh [-h] [-e]

  -h    Show this message.
  -e    Check script dependencies and exit.
EOF
}

check_dependencies() {
    local cmds=(awk)
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

main() {
    local type="${BLOCK_INSTANCE:-mem}"
    local percent="${PERCENT:-true}"

    awk -v type="${type}" -v percent="${percent}" '
BEGIN {
    kib_to_gib = 1024 * 1024
}
/^MemTotal:/      { mem_total = $2 }
/^MemFree:/       { mem_free  = $2 }
/^Buffers:/       { buffers   = $2 }
/^Cached:/        { cached    = $2 }
/^MemAvailable:/  { mem_avail = $2 }
/^SwapTotal:/     { swap_total = $2 }
/^SwapFree:/      { swap_free  = $2 }

END {
    if (type == "swap") {
        used = (swap_total - swap_free) / kib_to_gib
        total = swap_total / kib_to_gib
    } else {
        if (mem_avail > 0) {
            used = (mem_total - mem_avail) / kib_to_gib
        } else {
            mem_free += buffers + cached
            used = (mem_total - mem_free) / kib_to_gib
        }
        total = mem_total / kib_to_gib
    }

    pct = (total > 0) ? (used / total * 100) : 0

    if (percent == "true") {
        printf("%.1fG/%.1fG (%.0f%%)\n", used, total, pct)
    } else {
        printf("%.1fG/%.1fG\n", used, total)
    }
}
' /proc/meminfo
}

while getopts ':he' opt; do
    case "${opt}" in
        h)
            usage
            exit 0
            ;;
        e)
            check_dependencies
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
