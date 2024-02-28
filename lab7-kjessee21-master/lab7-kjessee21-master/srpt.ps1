#!/usr/bin/env pwsh
# Kaden Jessee
# Lab 7 - PowerShell Search and Report
# CS 3030 - Scripting languages
if ($args.Length -ne 1) {
    Write-Host "Usage: srpt.ps1 FOLDER"
    exit 1
}

# Initialize variables to hold counts
$directoryCount = 0
$fileCount = 0
$symLinkCount = 0
$oldFileCount = 0
$largeFileCount = 0
$graphicsFileCount = 0
$temporaryFileCount = 0
$executableFileCount = 0
$totalFileSize = 0
#changing for github update
# Get the current date and hostname
$currentDate = Get-Date
$hostname = [System.Net.Dns]::GetHostName()

# Recursive search of the specified folder
$folder = Get-ChildItem -Recurse -Path $args[0]

foreach ($item in $folder) {
    if ($item.PSIsContainer -and $item.FullName -ne $args[0]) {
        # Count subdirectories
        $directoryCount++
    }
    elseif ($item.PSIsContainer -eq $false) {
        if(-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)){
            #count regular files
            $fileCount++
        }
        
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            # Count symbolic links
            $symLinkCount++
        }
        elseif ($item.CreationTime -lt (Get-Date).AddDays(-365)) {
            # Count old files
            $oldFileCount++
        }
        
        if ($item.Length -gt 500000) {
            # Count large files
            $largeFileCount++
        }
        #graphics files need the '$' included
        if ($item.Name -match '\.jpg$|\.gif$|\.bmp$') {
            if(-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)){
                $graphicsFileCount++
            }
        }
        elseif ($item.Extension -eq ".o") {
            if(-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)){
                $temporaryFileCount++
            }
        }
        
        if ($item.Extension -match '\.bat$|\.ps1$|\.exe$') {
            if(-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)){
                $executableFileCount++
            }
        }
        
        # Accumulate total byte count (exclude symbolic links)
        if (-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            $totalFileSize += $item.Length
        }
    }
}

# Print the report
Write-Host "SearchReport $hostname $($args[0]) $($currentDate.ToString("MM/dd/yyyy HH:mm:ss"))"
Write-Host "Execution time $($Env:SECONDS)"
Write-Host "Directories $('{0:N0}' -f $directoryCount)"
Write-Host "Files $('{0:N0}' -f $fileCount)"
Write-Host "Sym links $('{0:N0}' -f $symLinkCount)"
Write-Host "Old files $('{0:N0}' -f $oldFileCount)"
Write-Host "Large files $('{0:N0}' -f $largeFileCount)"
Write-Host "Graphics files $('{0:N0}' -f $graphicsFileCount)"
Write-Host "Temporary files $('{0:N0}' -f $temporaryFileCount)"
Write-Host "Executable files $('{0:N0}' -f $executableFileCount)"
Write-Host "TotalFileSize $('{0:N0}' -f $totalFileSize)"

exit 0