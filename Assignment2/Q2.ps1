# Q2: Collect system, resource, disk, and network information.
$ErrorActionPreference = "Stop"
$ReportPath = Join-Path $PSScriptRoot "Q2.txt"

try {
    $OS = Get-CimInstance Win32_OperatingSystem
    $Computer = Get-CimInstance Win32_ComputerSystem

    # Read the current overall CPU utilization counter.
    $CPU = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor `
        -Filter "Name='_Total'"

    $Disk = Get-CimInstance Win32_LogicalDisk `
        -Filter "DeviceID='$($env:SystemDrive)'"

    $Report = @(
        "========================================"
        "Q2 - SYSTEM AND NETWORK MONITORING"
        "========================================"
        ""
        "SYSTEM INFORMATION"
        "Computer name: $env:COMPUTERNAME"
        "Operating system: $($OS.Caption)"
        "OS version: $($OS.Version)"
        ""
        "CPU AND MEMORY"
        "CPU utilization: $($CPU.PercentProcessorTime)%"
        "Total physical memory: $([math]::Round($Computer.TotalPhysicalMemory / 1GB,2)) GB"
        "Available physical memory: $([math]::Round(($OS.FreePhysicalMemory * 1KB) / 1GB,2)) GB"
        ""
        "SYSTEM DISK: $env:SystemDrive"
        "Total space: $([math]::Round($Disk.Size / 1GB,2)) GB"
        "Available space: $([math]::Round($Disk.FreeSpace / 1GB,2)) GB"
        ""
        "ACTIVE NETWORK CONFIGURATION"
    )

    $Configurations = @(Get-NetIPConfiguration | Where-Object {
        $_.NetAdapter.Status -eq "Up" -and $_.IPv4Address
    })

    if ($Configurations.Count -eq 0) {
        $Report += "No active IPv4 configuration found."
    }
    else {
        foreach ($Configuration in $Configurations) {
            $Report += "Adapter: $($Configuration.InterfaceAlias)"
            $Report += "IPv4 address: $($Configuration.IPv4Address.IPAddress -join ', ')"

            $Gateway = $Configuration.IPv4DefaultGateway.NextHop -join ", "
            if (-not $Gateway) { $Gateway = "None configured" }

            $Report += "Default gateway: $Gateway"
            $Report += ""
        }
    }

    $PingOK = Test-Connection -ComputerName 8.8.8.8 `
        -Count 2 -Quiet -ErrorAction SilentlyContinue

    $Report += "CONNECTIVITY TEST TO 8.8.8.8"
    if ($PingOK) {
        $Report += "ICMP connectivity: SUCCESS"
    }
    else {
        $Report += "ICMP connectivity: FAILED (no ping reply)"
    }

    $Report += ""
    $Report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    $Report | Set-Content -LiteralPath $ReportPath -Encoding UTF8
    Get-Content -LiteralPath $ReportPath
    Write-Host "`nSUCCESS: Q2.txt created."
}
catch {
    Write-Error "Q2 failed: $($_.Exception.Message)"
    exit 1
}
