$disks = Get-Disk | Where-Object { $_.PartitionStyle -ne 'RAW' }

foreach ($disk in $disks) {
    Get-Partition -DiskNumber $disk.Number | Where-Object { -not ($_.IsBoot -or $_.IsSystem) } | Remove-Partition -Confirm:$false
    
    Get-Partition -DiskNumber $disk.Number | New-Partition -UseMaximumSize -AssignDriveLetter | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "Formatted_$($disk.Number)" -Force
}
