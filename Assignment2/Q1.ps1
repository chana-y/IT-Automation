# Q1: Collect cumulative process CPU time and optionally register scheduling.
param([switch]$RegisterTask)

$ErrorActionPreference = "Stop"
$ReportPath = Join-Path $PSScriptRoot "Q1.txt"
$TaskName = "CIS4431_Assignment2_Q1"

try {
    $Report = @(
        "========================================"
        "Q1 - PROCESS CPU TIME AND SCHEDULING"
        "========================================"
        "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        ""
        "TOP FIVE PROCESSES BY CUMULATIVE CPU TIME"
        "CPU time is measured in seconds, not current CPU percentage."
    )

    $Processes = Get-Process |
        Where-Object { $null -ne $_.CPU } |
        Sort-Object CPU -Descending |
        Select-Object -First 5 ProcessName, Id,
            @{Name="CPUSeconds";Expression={[math]::Round($_.CPU,2)}}

    $Report += ($Processes | Format-Table -AutoSize | Out-String -Width 180)

    if ($RegisterTask) {
        # Use absolute paths so Task Scheduler can locate the script.
        $PowerShellExe = Join-Path $env:SystemRoot `
            "System32\WindowsPowerShell\v1.0\powershell.exe"

        $Action = New-ScheduledTaskAction `
            -Execute $PowerShellExe `
            -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
            -WorkingDirectory $PSScriptRoot

        $Trigger = New-ScheduledTaskTrigger -Daily -At "09:00"

        # SYSTEM allows the local task to run without storing a user password.
        $Principal = New-ScheduledTaskPrincipal `
            -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        $Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

        Register-ScheduledTask -TaskName $TaskName `
            -Action $Action -Trigger $Trigger `
            -Principal $Principal -Settings $Settings `
            -Description "Assignment 2: daily process CPU report at 9 AM" `
            -Force | Out-Null
    }

    $Task = Get-ScheduledTask -TaskName $TaskName
    $TaskInfo = Get-ScheduledTaskInfo -TaskName $TaskName

    $Report += ""
    $Report += "REGISTERED SCHEDULED TASK"
    $Report += "Task name: $($Task.TaskName)"
    $Report += "State: $($Task.State)"
    $Report += "Account: $($Task.Principal.UserId)"
    $Report += "Trigger: Daily at 9:00 AM (Windows local time)"
    $Report += "Start boundary: $($Task.Triggers[0].StartBoundary)"
    $Report += "Next run: $($TaskInfo.NextRunTime)"
    $Report += "Script: $PSCommandPath"

    $Report | Set-Content -LiteralPath $ReportPath -Encoding UTF8
    Get-Content -LiteralPath $ReportPath
    Write-Host "`nSUCCESS: Q1.txt created and scheduled task verified."
}
catch {
    Write-Error "Q1 failed: $($_.Exception.Message)"
    exit 1
}
