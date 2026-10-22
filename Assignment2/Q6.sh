#!/bin/bash
# Q6: Report top CPU processes and maintain a daily user cron job.
set -Eeuo pipefail
export LC_ALL=C
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
script_path="$script_dir/Q6.sh"
report="$script_dir/Q6.txt"
cron_temp=""

cleanup() {
    if [[ -n "$cron_temp" ]]; then
        rm -f -- "$cron_temp"
    fi
}
trap cleanup EXIT
trap 'echo "ERROR: Q6 failed near line $LINENO." >&2' ERR

chmod u+x "$script_path"

{
    echo "========================================"
    echo "Q6 - CPU PROCESSES AND CRON SCHEDULING"
    echo "========================================"
    echo "Generated: $(date -Is)"
    echo "Crontab owner: $(id -un)"

    echo
    echo "TOP FIVE PROCESSES BY CPU PERCENTAGE"
    echo "ps %CPU is CPU use averaged over each process lifetime."
    ps -eo pid,user:32,comm,pcpu --sort=-pcpu | sed -n '1,6p'

    echo
    echo "CONFIGURE DAILY 9:00 AM CRON JOB"

    # Preserve unrelated cron jobs and replace only this assignment's entry.
    cron_temp="$(mktemp)"
    if existing_cron="$(crontab -l 2>&1)"; then
        printf '%s\n' "$existing_cron" |
            sed '/# CIS4431_ASSIGNMENT2_Q6$/d' > "$cron_temp"
    elif [[ "$existing_cron" == *"no crontab for"* ]]; then
        : > "$cron_temp"
    else
        echo "ERROR: Unable to read the current user's crontab."
        printf '%s\n' "$existing_cron"
        exit 1
    fi

    # Escape percent characters because cron treats unescaped % specially.
    cron_path="${script_path//%/\\%}"
    printf '0 9 * * * /bin/bash "%s" >/dev/null 2>&1 # CIS4431_ASSIGNMENT2_Q6\n' \
        "$cron_path" >> "$cron_temp"

    crontab "$cron_temp"

    echo
    echo "VERIFIED CRON ENTRY"
    crontab -l | grep -F '# CIS4431_ASSIGNMENT2_Q6'

    echo
    echo "Schedule: daily at 9:00 AM in the Ubuntu system timezone."
    timedatectl show --property=Timezone --value

    echo
    echo "Execution permissions:"
    ls -l "$script_path"
} 2>&1 | tee "$report"

[[ -s "$report" ]] || {
    echo "ERROR: Q6.txt is missing or empty." >&2
    exit 1
}
echo
echo "SUCCESS: Q6.txt created and current user's cron entry verified."
