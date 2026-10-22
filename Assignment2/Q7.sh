#!/bin/bash
# Q7: Collect Ubuntu system, resource, disk, and network information.
set -Eeuo pipefail
export LC_ALL=C
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
report="$script_dir/Q7.txt"

trap 'echo "ERROR: Q7 failed near line $LINENO." >&2' ERR

{
    echo "========================================"
    echo "Q7 - UBUNTU SYSTEM AND NETWORK MONITORING"
    echo "========================================"

    echo
    echo "SYSTEM INFORMATION"
    echo "Hostname: $(hostname)"
    . /etc/os-release
    echo "Operating system: $PRETTY_NAME"

    echo
    echo "CPU INFORMATION"
    lscpu | grep -E '^(Model name:|CPU\(s\):)'
    echo "Online logical processors: $(getconf _NPROCESSORS_ONLN)"

    echo
    echo "PHYSICAL MEMORY"
    # The Mem row includes total and available physical memory.
    free -h

    echo
    echo "DISK UTILIZATION"
    # Show total, used, available, and utilization percentage.
    df -h -x tmpfs -x devtmpfs

    echo
    echo "ACTIVE NETWORK INTERFACES AND IP ADDRESSES"
    ip -br address show up

    echo
    echo "CONNECTIVITY TEST TO 8.8.8.8"
    if ping -c 2 -W 3 8.8.8.8; then
        echo "Connectivity test: SUCCESS"
    else
        echo "Connectivity test: FAILED (no ping reply)"
    fi

    echo
    echo "Generated: $(date -Is)"
} 2>&1 | tee "$report"

[[ -s "$report" ]] || {
    echo "ERROR: Q7.txt is missing or empty." >&2
    exit 1
}
echo
echo "SUCCESS: Q7.txt created."
