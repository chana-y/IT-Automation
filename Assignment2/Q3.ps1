# Q3: Troubleshoot Windows services and connectivity to an authorized VM.
param(
    [Parameter(Mandatory=$true)]
    [string]$RemoteComputer
)

$ErrorActionPreference = "Stop"
$ReportPath = Join-Path $PSScriptRoot "Q3.txt"

try {
    $Report = @(
        "========================================"
        "Q3 - WINDOWS TROUBLESHOOTING"
        "========================================"
        "Computer name: $env:COMPUTERNAME"
        "Current user: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        "Authorized remote target: $RemoteComputer"
        "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        ""
        "STOPPED WINDOWS SERVICES"
    )

    $Stopped = @(Get-Service |
        Where-Object Status -eq "Stopped" |
        Sort-Object Name |
        Select-Object Name, DisplayName, Status)

    if ($Stopped.Count -gt 0) {
        $Report += ($Stopped | Format-Table -AutoSize | Out-String -Width 200)
    }
    else {
        $Report += "No stopped services found."
    }

    $Report += ""
    $Report += "WINDOWS UPDATE SERVICE"

    try {
        $UpdateService = Get-Service -Name wuauserv
        $Report += "Name: $($UpdateService.Name)"
        $Report += "Status: $($UpdateService.Status)"
    }
    catch {
        $Report += "Service query failed: $($_.Exception.Message)"
    }

    $Report += ""
    $Report += "REMOTE CONNECTIVITY TESTS"

    $PingOK = Test-Connection -ComputerName $RemoteComputer `
        -Count 2 -Quiet -ErrorAction SilentlyContinue

    if ($PingOK) {
        $Report += "ICMP test to ${RemoteComputer}: SUCCESS"
    }
    else {
        $Report += "ICMP test to ${RemoteComputer}: FAILED (no ping reply)"
    }

    $SSHOK = Test-NetConnection -ComputerName $RemoteComputer `
        -Port 22 -InformationLevel Quiet -WarningAction SilentlyContinue `
        -ErrorAction SilentlyContinue

    if ($SSHOK) {
        $Report += "SSH TCP port 22 test: SUCCESS"
    }
    else {
        $Report += "SSH TCP port 22 test: FAILED"
    }

    $Report | Set-Content -LiteralPath $ReportPath -Encoding UTF8

    # Display the complete report, followed by a concise screenshot summary.
    Get-Content -LiteralPath $ReportPath
    Write-Host "`nSCREENSHOT SUMMARY"
    Write-Host "Computer: $env:COMPUTERNAME"
    Write-Host "User: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    Write-Host "Stopped services found: $($Stopped.Count)"
    $Stopped | Select-Object -First 5 | Format-Table -AutoSize
    $Report | Select-Object -Last 7
    Write-Host "`nSUCCESS: Q3.txt created; full stopped-service list is in the report."
}
catch {
    Write-Error "Q3 failed: $($_.Exception.Message)"
    exit 1
}
