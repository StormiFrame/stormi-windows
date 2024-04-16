@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

set "workbenchPath=%CD%\%1\server\rpcProtos"

set "flag=0"

for %%i in (%1\server\rpcProtos\*.proto) do (
    set "flag=1"
    set filename=%%~ni
    set foldername=ProtoCode\!filename!

    if not exist "!workbenchPath!\!foldername!" (
        mkdir "!workbenchPath!\!foldername!"
    )

    protoc --go_out=%1\server\rpcProtos\!foldername! %%i
    protoc --go-grpc_out="%1\server\rpcProtos\!foldername!" "%%i"
)

if "!flag!"=="0" exit
endlocal


call %~dp0\stormi-initserverset.bat %CD%\%1\server\rpcProtos