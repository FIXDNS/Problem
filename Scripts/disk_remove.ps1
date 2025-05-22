$excludedFoldersAndFiles = @(
    "${env:SystemRoot}*",
    "${env:ProgramFiles}*",
    "${env:ProgramFiles(x86)}*",
    "${env:USERPROFILE}*",
    "${env:SYSTEMDRIVE}\System Volume Information*",
    "${env:SYSTEMDRIVE}\PerfLogs*",
    "${env:SYSTEMDRIVE}\ProgramData*",
    "${env:SYSTEMDRIVE}\pagefile.sys",
    "${env:SYSTEMDRIVE}\hiberfil.sys",
    "${env:SYSTEMDRIVE}\swapfile.sys"
)

$physicalDisks = Get-CimInstance Win32_LogicalDisk | Where-Object DriveType -eq 3 | Select-Object Name

foreach ($disk in $physicalDisks.Name) {
    Write-Host "Обрабатываю диск: $disk" -ForegroundColor Yellow

    $filesAndFolders = Get-ChildItem -Path "$disk\" -Recurse -Force -ErrorAction SilentlyContinue

    foreach ($item in $filesAndFolders) {
        if ($excludedFoldersAndFiles | Where-Object { $item.FullName -like $_ }) {
            continue
        }

        try {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop -Confirm:$false
            Write-Host "Удалён объект: $($item.FullName)" -ForegroundColor Green
        } catch {
            Write-Warning "Ошибка при удалении объекта '$($item.FullName)': $($_.Exception.Message)"
        }
    }
}

Write-Host "Очистка завершена." -ForegroundColor Cyan
