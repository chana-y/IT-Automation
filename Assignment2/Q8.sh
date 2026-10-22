#!/bin/bash
# Q8: Ensure OpenSSH server is installed and collect SSH diagnostics.
set -Eeuo pipefail
export LC_ALL=C
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
report="$script_dir/Q8.txt"

trap 'echo "ERROR: Q8 failed near line $LINENO. Review the output/report." >&2' ERR

sudo -v

{
    echo "========================================"
    echo "Q8 - UBUNTU SSH TROUBLESHOOTING"
    echo "========================================"
    echo "Generated: $(date -Is)"
    echo "Hostname: $(hostname)"
    echo "Username: $(id -un)"

    echo
    echo "OPENSSH SERVER INSTALLATION CHECK"
    package_status="$(dpkg-query -W -f='${Status}' openssh-server 2>/dev/null || true)"

    if [[ "$package_status" == "install ok installed" ]]; then
        echo "OpenSSH server is already installed."
    else
        echo "OpenSSH server is not installed. Installing it now."
        sudo apt-get update --error-on=any
        sudo apt-get install -y openssh-server
    fi

    dpkg-query -W -f='Package: ${Package}\nVersion: ${Version}\nStatus: ${Status}\n' openssh-server

    echo
    echo "SSH SERVICE STATUS BEFORE START CHECK"
    # An inactive service returns a nonzero status; report it without aborting.
    systemctl is-active ssh.service || true

    if ! systemctl is-active --quiet ssh.service; then
        echo "Starting SSH service."
        sudo systemctl start ssh.service
    fi

    echo
    echo "SSH SERVICE STATUS"
    sudo systemctl status ssh.service --no-pager --full

    echo
    echo "NETWORK INTERFACES AND IPv4 ADDRESSES"
    ip -br -4 address show up

    echo
    echo "DEFAULT ROUTE"
    ip -4 route show default

    echo
    echo "TCP PORT 22 LISTENERS"
    sudo ss -ltnp 'sport = :22'

    echo
    echo "SSH ED25519 HOST PUBLIC-KEY FINGERPRINT"
    # This is a public fingerprint, not a private key.
    if [[ -f /etc/ssh/ssh_host_ed25519_key.pub ]]; then
        ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
    else
        echo "ED25519 public host key is unavailable."
    fi

    echo
    echo "FIREWALL STATUS"
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw status
    else
        echo "UFW command is not installed."
    fi
} 2>&1 | tee "$report"

if [[ -f "$report" && -s "$report" ]]; then
    echo
    echo "SUCCESS: Q8.txt created."
else
    echo "ERROR: Q8.txt is missing or empty." >&2
    exit 1
fi
