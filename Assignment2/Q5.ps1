# Q5: Read installed update history, service status, and restore points.
$ErrorActionPreference = "Stop"
$ReportPath = Join-Path $PSScriptRoot "Q5.txt"

try {
    $Report = @(
        "========================================"
        "Q5 - WINDOWS PATCH AND RESTORE INFORMATION"
        "========================================"
        ""
        "FIVE MOST RECENT INSTALLED UPDATES"
        "Source: Get-HotFix; some update types are not included."
    )

    try {
        $Updates = @(Get-HotFix |
            Sort-Object InstalledOn -Descending |
            Select-Object -First 5 HotFixID, InstalledOn)

        if ($Updates.Count -gt 0) {
            $Report += ($Updates | Format-Table -AutoSize | Out-String -Width 160)
        }
        else {
            $Report += "No installed hotfix records are available."
        }
    }
    catch {
        $Report += "Update information unavailable: $($_.Exception.Message)"
    }

    $Report += ""
    $Report += "WINDOWS UPDATE SERVICE"

    try {
        $Service = Get-Service -Name wuauserv
        $Report += "Name: $($Service.Name)"
        $Report += "Status: $($Service.Status)"
    }
    catch {
        $Report += "Service information unavailable: $($_.Exception.Message)"
    }

    $Report += ""
    $Report += "SYSTEM RESTORE POINTS"

    try {
        $Points = @(Get-ComputerRestorePoint)

        if ($Points.Count -gt 0) {
            $Report += "Restore points available: YES"
            $Report += ($Points |
                Select-Object SequenceNumber, Description, CreationTime |
                Format-Table -AutoSize | Out-String -Width 200)
        }
        else {
            $Report += "No restore points were returned."
            $Report += "System Protection may be disabled or no points have been created."
        }
    }
    catch {
        $Report += "Restore-point information unavailable or unsupported."
        $Report += "Details: $($_.Exception.Message)"
    }

    $Report += ""
    $Report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $Report += "No Windows updates were installed or uninstalled."

    $Report | Set-Content -LiteralPath $ReportPath -Encoding UTF8
    Get-Content -LiteralPath $ReportPath
    Write-Host "`nSUCCESS: Q5.txt created."
}
catch {
    Write-Error "Q5 report generation failed: $($_.Exception.Message)"
    exit 1
}
