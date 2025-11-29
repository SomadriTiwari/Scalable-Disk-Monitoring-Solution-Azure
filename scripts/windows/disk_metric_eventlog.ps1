$volumes = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"

foreach ($v in $volumes) {
    $freePercent = [math]::Round(($v.FreeSpace / $v.Size) * 100, 2)
    $msg = "Disk: $($v.DeviceID), Free: $freePercent%"

    # Create source if missing
    if (-not [System.Diagnostics.EventLog]::SourceExists("DiskMonitor")) {
        New-EventLog -LogName Application -Source "DiskMonitor"
    }

    Write-EventLog -LogName Application -Source "DiskMonitor" `
        -EventId 3001 -EntryType Information -Message $msg
}
