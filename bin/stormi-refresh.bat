@echo off

setlocal enabledelayedexpansion
chcp 65001 > nul

set "path=%CD%"
for %%A in ("%path%") do (
    set "output=%%~dpA"
)
set "output=%output:~0,-1%"
for %%A in ("%output%") do (
    set "output=%%~dpA"
)
set "output=%output:~0,-1%"
for %%A in ("%output%") do (
    set "output=%%~dpA"
)


set "workbenchpath=%output:~0,-1%"、

set "appserversetpath=%workbenchpath%\appserverset"

copy "%appserversetpath%\*" "%CD%" > nul

endlocal



for %%i in (*.proto) do (
    set filename=%%~ni
    set foldername=ProtoCode\!filename!

    if not exist "!foldername!" (
        mkdir "!foldername!"
    )

    protoc --go_out=!foldername! %%i
    protoc --go-grpc_out=!foldername! %%i
)



call %~dp0\stormi-serversetinit.bat %CD%