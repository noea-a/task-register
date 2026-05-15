$tempFile = "$env:TEMP\task_register_input.txt"

if (-not (Test-Path $tempFile)) {
    Write-Host "Input file not found: $tempFile"
    pause
    exit 1
}

$inputPath = (Get-Content $tempFile -Raw).Trim()
Remove-Item $tempFile -Force

& "$PSScriptRoot\register.ps1" $inputPath
