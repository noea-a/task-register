param([string]$InputPath)

if (-not $InputPath -or -not (Test-Path $InputPath)) {
    Write-Host "Usage: Drop a .cmd or .lnk file onto reg_admin_task.cmd"
    pause
    exit 1
}

if ([System.IO.Path]::GetExtension($InputPath) -ieq '.lnk') {
    $shell = New-Object -COM WScript.Shell
    $InputPath = $shell.CreateShortcut($InputPath).TargetPath
}

$taskName = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)

$toolRoot   = Split-Path $PSScriptRoot -Parent
$taskFolder = "\task-register\"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$InputPath`""
    exit
}

$action    = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$InputPath`""
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest -LogonType Interactive
$settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $taskName -TaskPath $taskFolder `
    -Action $action -Principal $principal -Settings $settings -Force | Out-Null

$desktop = [System.Environment]::GetFolderPath('Desktop')
$sh  = New-Object -COM WScript.Shell
$lnk = $sh.CreateShortcut("$desktop\$taskName.lnk")
$lnk.TargetPath  = "schtasks.exe"
$lnk.Arguments   = "/run /tn `"$taskFolder$taskName`""
$lnk.WindowStyle = 7
$lnk.Save()

$deleteCmdsDir = Join-Path $toolRoot "delete-cmds"
if (-not (Test-Path $deleteCmdsDir)) {
    New-Item -ItemType Directory -Path $deleteCmdsDir | Out-Null
}
$deleteCmdPath = Join-Path $deleteCmdsDir "$taskName.cmd"
@"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\data\unregister.ps1" "$taskName" "%~f0"
"@ | Set-Content -Encoding ASCII -Path $deleteCmdPath

Write-Host "Registered : $taskFolder$taskName"
Write-Host "Desktop LNK: $desktop\$taskName.lnk"
Write-Host "Delete CMD : $deleteCmdPath"
pause
