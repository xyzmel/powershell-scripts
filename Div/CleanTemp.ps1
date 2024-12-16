# Delete temporary files
$TempDirs = @("C:\Windows\Temp", "$env:USERPROFILE\AppData\Local\Temp", "C:\Temp")
foreach ($dir in $TempDirs) {
    if (Test-Path $dir) {
        Write-Host "Deleting files from $dir" -ForegroundColor Yellow
        Remove-Item "$dir\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Clear Recycle Bin
$recycleBin = New-Object -ComObject Shell.Application
$recycleBin.NameSpace('shell:::{645FF040-5081-101B-9F08-00AA002F954E}').Items() | ForEach-Object { $_.InvokeVerb('delete') }

Write-Host "Disk cleanup complete." -ForegroundColor Green
