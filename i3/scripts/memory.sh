#!/bin/bash

TYPE="${BLOCK_INSTANCE:-mem}"
PERCENT="${PERCENT:-true}"

awk -v type="$TYPE" -v percent="$PERCENT" '
BEGIN {
    kib_to_gib = 1024 * 1024  # Use binary units (GiB)
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
        # Prefer MemAvailable if present
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
