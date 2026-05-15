@echo off
echo %~f1> "%TEMP%\task_register_input.txt"
schtasks /run /tn "\task-register\reg_admin_task"
