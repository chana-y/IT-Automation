# Q4: Generate inventory and validate the saved report.
$ErrorActionPreference = "Stop"
$ReportPath = Join-Path $PSScriptRoot "Q4.txt"

try {
    $OS = Get-CimInstance Win32_OperatingSystem
    $Computer = Get-CimInstance Win32_ComputerSystem
    $Processors = Get-CimInstance Win32_Processor

    $Report = @(
        "========================================"
        "Q4 - WINDOWS SYSTEM INVENTORY"
        "========================================"
        "Computer name: $env:COMPUTERNAME"
        "Operating system: $($OS.Caption)"
        "OS version: $($OS.Version)"
        "Processor model: $(($Processors.Name) -join '; ')"
        "Installed physical memory: $([math]::Round($Computer.TotalPhysicalMemory / 1GB,2)) GB"
        ""
        "INSTALLED NETWORK ADAPTERS"
    )

    $Adapters = Get-NetAdapter -IncludeHidden |
        Select-Object Name, InterfaceDescription, Status

    $Report += ($Adapters | Format-Table -AutoSize | Out-String -Width 200)
    $Report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    $Report | Set-Content -LiteralPath $ReportPath -Encoding UTF8

    # Explicitly verify existence and nonzero size.
    if (-not (Test-Path -LiteralPath $ReportPath -PathType Leaf)) {
        throw "The inventory report was not created."
    }

    $File = Get-Item -LiteralPath $ReportPath
    if ($File.Length -le 0) {
        throw "The inventory report is empty."
    }

    Get-Content -LiteralPath $ReportPath
    Write-Host "`nSUCCESS: Q4.txt exists and contains $($File.Length) bytes."
}
catch {
    Write-Host "FAILURE: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
