param([string]$TaskName, [string]$SelfPath)

if (-not $TaskName) {
    Write-Host "Usage: unregister.ps1 <TaskName>"
    pause
    exit 1
}

$toolRoot   = Split-Path $PSScriptRoot -Parent
$taskFolder = "\task-register\"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$TaskName`" `"$SelfPath`""
    exit
}

$task = Get-ScheduledTask -TaskName $TaskName -TaskPath $taskFolder -ErrorAction SilentlyContinue
if (-not $task) {
    Write-Host "Task not found: $taskFolder$TaskName"
    pause
    exit 1
}

Unregister-ScheduledTask -TaskName $TaskName -TaskPath $taskFolder -Confirm:$false
Write-Host "Unregistered: $taskFolder$TaskName"

if ($SelfPath -and (Test-Path $SelfPath)) {
    Remove-Item -Path $SelfPath -Force
    Write-Host "Deleted CMD : $SelfPath"
}
pause
