@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$s = (New-Object -COM WScript.Shell).CreateShortcut([Environment]::GetFolderPath('SendTo') + '\reg_admin_task.cmd.lnk');" ^
  "$s.TargetPath = '%~dp0reg_admin_task.cmd'; $s.Save();"
echo Created shortcut in SendTo folder.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0data\setup_task.ps1"
