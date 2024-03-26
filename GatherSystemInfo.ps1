<# 
Script Name: GatherSystemInfo.ps1
Description: This script collects and logs system information for a specific room location and device.
             It retrieves details like system model, device type, hardware specifications, OS details, and performance metrics.
Output: Log file containing the gathered information.
#>

# Prompt for Room and device info
$Room = Read-Host -Prompt "Enter Room Location"
$deviceInfo = Read-Host -Prompt "Enter Device Information"

# Function to format system model information
function Format-SystemModel {
    param (
        [Parameter(Mandatory=$true)]
        $SystemModelInfo
    )

    if ($SystemModelInfo.Manufacturer -eq "System manufacturer" -and $SystemModelInfo.Model -eq "System Product Name") { 
        return "Custom Build" 
    } else { 
        return "$($SystemModelInfo.Manufacturer) $($SystemModelInfo.Model)" 
    }
}

# Function to get formatted system age
function Get-FormattedSystemAge {
    $biosDate = [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject -Class Win32_BIOS).ReleaseDate)
    $currentDate = Get-Date
    $age = New-TimeSpan -Start $biosDate -End $currentDate
    $years = [math]::Floor($age.TotalDays / 365)
    $months = [math]::Floor(($age.TotalDays % 365) / 30)
    $days = [math]::Floor($age.TotalDays % 30)
    return "$years years, $months months, $days days old"
}

# Function to format storage information
function Format-StorageInfo {
    param (
        [Parameter(Mandatory=$true)]
        $StorageInfo
    )

    $storageFormatted = $StorageInfo | ForEach-Object {
        "$($_.Name): Used Space: $($_.Used / 1GB -as [int]) GB, Free Space: $($_.Free / 1GB -as [int]) GB, Used(%): $($_.'Used(%)')"
    }

    return $storageFormatted -join '; '
}

# Function to format RAM information
function Format-RAMInfo {
    param (
        [Parameter(Mandatory=$true)]
        $RAMInfo
    )

    $totalRam = ($RAMInfo | Measure-Object Capacity -Sum).Sum / 1GB
    $ramType = $RAMInfo[0].Type
    return "Total: $totalRam GB, Type: $ramType"
}

# Function to format OS information
function Format-OSInfo {
    param (
        [Parameter(Mandatory=$true)]
        $OSInfo
    )

    return "$($OSInfo.Caption) (Version: $($OSInfo.Version))"
}

# Function to get the last logged in users
function Get-LastLoggedInUsers {
    param (
        [Parameter(Mandatory=$true)]
        [int]
        $MaxEvents
    )

    $lastUsers = Get-WinEvent -LogName Security -FilterXPath "*[System[EventID=4624]]" -MaxEvents $MaxEvents |
                 Select-Object @{Name='User'; Expression={$_.Properties[5].Value}} -Unique

    return $lastUsers.User -join ', '
}

# Function to format OS details
function Format-OSDetails {
    $osInstallDateFormatted = [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject -Class Win32_OperatingSystem).InstallDate)
    $lastBootUpTime = [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject -Class Win32_OperatingSystem).LastBootUpTime)
    $systemUptimeFormatted = New-TimeSpan -Start $lastBootUpTime -End (Get-Date)
    return "Install Date: $osInstallDateFormatted, Uptime: $($systemUptimeFormatted.Days) Days, $($systemUptimeFormatted.Hours) Hours"
}

# Function to get antivirus status
function Get-AntivirusStatus {
    try {
        $antivirusStatus = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct
        if ($antivirusStatus) {
            return ($antivirusStatus | ForEach-Object { $_.displayName }) -join ', '
        } else {
            return "Not Detected/Not Reporting"
        }
    } catch {
        Write-Warning "Unable to determine antivirus status. Error: $_"
        return "Unavailable"
    }
}

# Function to get performance information
function Get-PerformanceInfo {
    $cpuLoadPercentage = (Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $cpuUsageFormatted = if ($cpuLoadPercentage -ne $null) { "$cpuLoadPercentage%" } else { "Unavailable" }

    $osMemory = Get-WmiObject -Class Win32_OperatingSystem
    $freeMemoryMB = $osMemory.FreePhysicalMemory
    $totalMemoryMB = $osMemory.TotalVisibleMemorySize
    $freeMemoryGB = [math]::Round($freeMemoryMB / 1MB, 2)
    $totalMemoryGB = [math]::Round($totalMemoryMB / 1MB, 2)
    $memoryUsageFormatted = "Free Memory: $freeMemoryGB GB, Total Memory: $totalMemoryGB GB"

    return "CPU Usage: $cpuUsageFormatted, Memory: $memoryUsageFormatted"
}

# Function to log system information
function Log-SystemInfo {
    param (
        [Parameter(Mandatory=$true)]
        $InfoObject,
        [Parameter(Mandatory=$true)]
        [string]
        $Room
    )

    $logFileName = "SystemInfoLog_Room_$Room.txt"
    $logFile = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('MyDocuments'), $logFileName)
    $InfoObject | Out-File $logFile -Force
}

# Function to display system information
function Display-SystemInfo {
    param (
        [Parameter(Mandatory=$true)]
        $InfoObject
    )

    $InfoObject | Format-Table -AutoSize
}

# Main function to gather and process system information
function Get-SystemInfo {
    try {
        $systemModelInfo = Get-WmiObject -Class Win32_ComputerSystem | Select-Object Manufacturer, Model
        $deviceType = if (Get-WmiObject -Class Win32_Battery) { "Laptop" } else { "Desktop/PC" }
        $graphicsCardInfo = Get-WmiObject -Class Win32_VideoController | Select-Object -First 1 Name
        $storageInfo = Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free, @{Name='Used(%)'; Expression={"{0:N2}%" -f (($_.Used / ($_.Used + $_.Free)) * 100)}}
        $ramInfo = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object @{Name='Type'; Expression={Switch ($_.SMBIOSMemoryType) {24 {'DDR3'} 26 {'DDR4'} Default {'Other'}}}}, Capacity
        $cpuInfo = Get-WmiObject -Class Win32_Processor | Select-Object Name, LoadPercentage
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version

        # Combine all information into a single object with formatted sections
        return [PSCustomObject]@{
            Room = $Room
            DeviceInfo = $deviceInfo
            SystemModel = Format-SystemModel -SystemModelInfo $systemModelInfo
            DeviceType = $deviceType
            GraphicsCard = $graphicsCardInfo.Name
            Storage = Format-StorageInfo -StorageInfo $storageInfo
            RAM = Format-RAMInfo -RAMInfo $ramInfo
            CPU = $cpuInfo.Name
            SystemAge = Get-FormattedSystemAge
            OS = Format-OSInfo -OSInfo $osInfo
            Hostname = $env:COMPUTERNAME
            Domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
            LastLoggedInUsers = Get-LastLoggedInUsers -MaxEvents 3
            OS_Details = Format-OSDetails
            Antivirus = Get-AntivirusStatus
            Performance = Get-PerformanceInfo
        }
    } catch {
        Write-Error "Failed to gather system information. Error: $_"
    }
}

# Execute and display results
$infoObject = Get-SystemInfo
if ($infoObject) {
    Log-SystemInfo -InfoObject $infoObject -Room $Room
    Display-SystemInfo -InfoObject $infoObject
}
