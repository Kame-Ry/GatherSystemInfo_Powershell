# Prompt user to select save location
Write-Host "Choose where to save the device information:" 
Write-Host "1. USB Drive (if available)"
Write-Host "2. Current directory"
$choice = Read-Host "Enter your choice (1 or 2)"
 
# Determine save path based on user choice
if ($choice -eq "1") {
    $removableDrives = Get-Volume | Where-Object { $_.DriveType -eq 'Removable' }
    if ($removableDrives) {
        Write-Host "Detected the following removable drives:"
        $removableDrives | ForEach-Object { Write-Host "$($_.DriveLetter): $($_.FileSystemLabel)" }
        $pendriveLetter = Read-Host "Enter the drive letter of the USB drive (e.g., D)"
        $outputPath = "$($pendriveLetter):\SiteAudit_DeviceInfo.csv"
    } else {
        Write-Host "No removable drives detected. Defaulting to script directory."
        $outputPath = Join-Path -Path (Get-Location) -ChildPath "SiteAudit_DeviceInfo.csv"
    }
} else {
    $outputPath = Join-Path -Path (Get-Location) -ChildPath "SiteAudit_DeviceInfo.csv"
}
 
# Check if the output file exists
$appendMode = Test-Path $outputPath
 
# Prompt user for additional information
$location = Read-Host "Enter the location of this device (e.g., Room 101, Lab A)"
$owner = Read-Host "Enter the name of the person this device belongs to (e.g., John Doe)"
$description = Read-Host "Enter a description for this device"
 
# Function to calculate detailed age
function Calculate-Age {
    param([datetime]$StartDate)
    $now = Get-Date
    $span = $now - $StartDate
    $years = ($span.Days / 365.25) -as [int]
    $remainingDays = $span.Days % 365.25
    $months = ($remainingDays / 30) -as [int]
    $days = $remainingDays % 30
    return "$years years, $months months, $days days"
}
 
# Function to get drive details
function Get-DriveStorageInfo {
    $drives = Get-Volume | Where-Object { $_.DriveLetter -ne $null }
    $result = @()
    foreach ($drive in $drives) {
        $totalSpaceGB = $drive.Size / 1GB
        $usedSpaceGB = ($drive.Size - $drive.SizeRemaining) / 1GB
        $percentUsed = if ($drive.Size -ne 0) {
            "{0:P2}" -f (($drive.Size - $drive.SizeRemaining) / $drive.Size)
        } else {
            "N/A"
        }
        $result += "$($_.DriveLetter): Total: {0:N2} GB, Used: {1:N2} GB, Usage: {2}" -f $totalSpaceGB, $usedSpaceGB, $percentUsed
    }
    return $result -join "; "
}
 
# Gather device information (ensure all columns are included)
$deviceInfo = [PSCustomObject]@{
    Timestamp         = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Location          = $location
    Owner             = $owner
    Description       = $description
    DeviceType        = if ((Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType -eq 1) { "Desktop" } else { "Laptop" }
    Brand             = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    Name              = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
    Model             = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version
    OS                = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    OSVersion         = (Get-CimInstance -ClassName Win32_OperatingSystem).Version
    LastBootTime      = ((Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime -as [datetime])
    RAM               = "{0:N2} GB" -f ((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    RAMPercentageUsed = ""
    Age               = Calculate-Age -StartDate ((Get-CimInstance -ClassName Win32_BIOS).ReleaseDate -as [datetime])
    CPU               = (Get-CimInstance -ClassName Win32_Processor).Name
    CPUUsage          = "{0:P2}" -f ((Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue / 100)
    Drives            = Get-DriveStorageInfo
    NetworkAdapters   = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object { "$($_.Name): $($_.MacAddress)" }) -join "; "
    IPAddresses       = (Get-NetIPAddress | Where-Object { $_.AddressState -eq "Preferred" -and $_.AddressFamily -eq "IPv4" } | ForEach-Object { "$($_.IPAddress) ($($_.InterfaceAlias))" }) -join "; "
}
 
# Export the information to the CSV
if ($appendMode) {
    $deviceInfo | Export-Csv -Path $outputPath -NoTypeInformation -Append
} else {
    $deviceInfo | Export-Csv -Path $outputPath -NoTypeInformation -Force
}
 
Write-Host "Device information exported to $outputPath"
