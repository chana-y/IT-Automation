#!/bin/bash
# Q9: Generate system inventory and verify report existence and content.
set -Eeuo pipefail
export LC_ALL=C
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
report="$script_dir/Q9.txt"

# A command or report-writing failure stops execution with an error message.
trap 'echo "ERROR: Q9 report generation failed near line $LINENO." >&2' ERR

{
    echo "========================================"
    echo "Q9 - UBUNTU SYSTEM INVENTORY"
    echo "========================================"

    echo
    echo "SYSTEM INFORMATION"
    echo "Hostname: $(hostname)"
    . /etc/os-release
    echo "Operating system: $PRETTY_NAME"

    echo
    echo "CPU INFORMATION"
    lscpu | grep -E '^(Architecture:|CPU\(s\):|Model name:|Thread\(s\) per core:|Core\(s\) per socket:)'

    echo
    echo "MEMORY INFORMATION"
    free -h

    echo
    echo "AVAILABLE NETWORK INTERFACES"
    ip -br link show

    echo
    echo "ASSIGNED IP ADDRESSES"
    ip -br address show

    echo
    echo "Generated: $(date -Is)"
} 2>&1 | tee "$report"

# Validate both requirements separately.
if [[ ! -f "$report" ]]; then
    echo "ERROR: Q9.txt does not exist." >&2
    exit 1
fi

if [[ ! -s "$report" ]]; then
    echo "ERROR: Q9.txt exists but is empty." >&2
    exit 1
fi

echo
echo "VALIDATION"
echo "Report exists: YES"
echo "Report contains data: YES"
echo "Report size: $(wc -c < "$report") bytes"
echo "SUCCESS: System inventory generation and verification passed."
