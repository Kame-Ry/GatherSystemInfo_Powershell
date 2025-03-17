# GatherSystemInfo.ps1

This PowerShell script collects comprehensive device information for site audits and inventory management. It prompts users for additional details such as the device location, owner, and a brief description, and then gathers extensive system and hardware data. The collected information—including system type, brand, model, operating system details, performance metrics, drive storage, network adapters, and IP addresses—is exported as a CSV file for easy analysis and documentation.

## Features

User Input Prompts:

    - Choose the save location (USB drive if available or current directory).
    - Enter device location (e.g., Room 101, Lab A), owner, and description.

System & Hardware Information:

    - Identifies device type (Desktop or Laptop), brand, and model.
    - Retrieves operating system details (caption and version) and last boot time.
    - Calculates detailed system age based on BIOS release date.
    - Gathers RAM size, CPU information, and current CPU usage.

Storage & Network Details:

    - Formats drive storage details including total space, used space, and usage percentage.
    - Retrieves active network adapter information and associated IP addresses.

Data Export:

    - Exports all collected data to a CSV file (SiteAudit_DeviceInfo.csv) in the chosen save location.

## Requirements

    - Windows PowerShell 5.1 or newer.
    - Administrative privileges may be required to access certain system information.

## Usage

    1. **Start PowerShell:** Open PowerShell with administrative privileges.
    2. **Execute the Script:** Navigate to the directory containing the script and run:
    .\GatherSystemInfo.ps1 
    3. **Enter Required Information:** When prompted, enter the room location and device information.

## Notes

- Ensure you have the necessary permissions to run scripts and access system information.
- The script may be modified to include additional system details as required.

https://roadmap.sh/projects/server-stats
