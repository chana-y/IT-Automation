#!/bin/bash
# Q10: Refresh package lists and simulate an upgrade without installing it.
set -Eeuo pipefail
export LC_ALL=C
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
report="$script_dir/Q10.txt"

trap 'echo "ERROR: Q10 failed near line $LINENO. Review the output/report." >&2' ERR

# Authenticate before starting report capture.
sudo -v

{
    echo "========================================"
    echo "Q10 - UBUNTU PATCH MANAGEMENT"
    echo "========================================"
    echo "Started: $(date -Is)"

    if [[ -f "$HOME/Assignment2_StartTime.txt" ]]; then
        echo "Recorded VM startup time:"
        cat "$HOME/Assignment2_StartTime.txt"
    fi

    echo
    echo "REFRESH PACKAGE INDEX"
    # Only refresh metadata; do not install upgrades.
    sudo apt-get update --error-on=any

    echo
    echo "PACKAGES WITH AVAILABLE UPDATES"
    apt list --upgradable

    echo
    echo "SIMULATED UPGRADE - NO UPDATES INSTALLED"
    sudo apt-get --simulate upgrade

    echo
    echo "Completed: $(date -Is)"
    echo "No actual package upgrade was performed."
} 2>&1 | tee "$report"

if [[ -f "$report" && -s "$report" ]]; then
    echo
    echo "SUCCESS: Q10.txt exists and contains $(wc -c < "$report") bytes."
else
    echo "ERROR: Q10.txt is missing or empty." >&2
    exit 1
fi
