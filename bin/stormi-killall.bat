@echo off

rem 获取脚本执行前的位置
set "original_dir=%CD%"

rem 启用延迟变量扩展
setlocal enabledelayedexpansion

for /d %%A in (*) do (
    rem 进入目录，如果失败则继续下一个循环
    cd "%%A" || continue

    rem 检查是否存在 processid 文件
    if exist "processid" (
        rem 读取 processid 文件中的 PID
        set /p pid=<processid
        tasklist /FI "PID eq !pid!" | findstr /C:"!pid!" > nul
        if %ERRORLEVEL% EQU 0 (
            taskkill /F /PID !pid!
        )
    )

    rem 返回脚本执行前的位置
    cd "%original_dir%"
)

rem 结束延迟变量扩展
endlocal
