# GatherSystemInfo.ps1

This PowerShell script collects detailed system information for a specific room location and device. It's designed to retrieve and log various system details including the system model, device type, hardware specifications, OS details, and performance metrics. The information is saved in a log file for further analysis or documentation purposes.

## Features

- Prompt for room location and device information.
- Collect system model, device type, and hardware specifications.
- Retrieve OS details and performance metrics.
- Log the gathered information in a structured format.
- Format and display storage, RAM, OS, and performance information.

## Requirements

- Windows PowerShell 5.1 or newer.
- Administrative privileges may be required to access certain system information.

## Usage

1. **Start PowerShell:** Open PowerShell with administrative privileges.
2. **Execute the Script:** Navigate to the directory containing the script and run:

    ```powershell
    .\GatherSystemInfo.ps1
    ```

3. **Enter Required Information:** When prompted, enter the room location and device information.

## Script Functions Overview

- **`Format-SystemModel`**: Formats the system model information for easy reading.
- **`Get-FormattedSystemAge`**: Calculates and formats the age of the system based on the BIOS release date.
- **`Format-StorageInfo`**: Formats storage device information including used space, free space, and used percentage.
- **`Format-RAMInfo`**: Gathers and formats RAM specifications.
- **`Format-OSInfo`**: Formats operating system details.
- **`Get-LastLoggedInUsers`**: Retrieves a list of the last logged-in users.
- **`Format-OSDetails`**: Formats operating system installation date and uptime.
- **`Get-AntivirusStatus`**: Checks and formats the antivirus status.
- **`Get-PerformanceInfo`**: Gathers and formats CPU and memory usage information.
- **`Log-SystemInfo`**: Logs the gathered system information to a file.
- **`Display-SystemInfo`**: Displays the gathered information in a formatted table.

## Output

The script generates a log file named `SystemInfoLog_Room_<Room Name>.txt` in the user's Documents folder. This file contains all the gathered system information in a structured and readable format.

## Notes

- Ensure you have the necessary permissions to run scripts and access system information.
- The script may be modified to include additional system details as required.
