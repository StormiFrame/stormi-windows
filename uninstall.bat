@echo off
setlocal enabledelayedexpansion
echo uninstall ......
rem 设置要删除的路径
set "path_to_remove=%CD%\bin"

rem 将 PATH 分割为单个项目
for %%i in ("%PATH:;=" "%") do (
    rem 检查当前项是否与要删除的路径匹配
    if /I not "%%~i"=="%path_to_remove%" (
        rem 将当前项添加到新的 PATH 变量中
        set "new_path=!new_path!;%%~i"
    )
)

rem 去除开始的分号
set "new_path=%new_path:~1%"

rem 更新环境变量 PATH
setx PATH "%new_path%"

echo Done!