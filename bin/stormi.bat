@echo off
chcp 65001 > nul

setlocal enabledelayedexpansion

set "scriptDir=%~dp0"

call "%scriptDir%\stormi-checkcommand.bat" %1

if "%1"=="version" (
    echo stormi-windows-1.1.0
    exit
)

if "%1"=="init" (
    copy "%scriptDir%\app.yaml" "%CD%"  > nul
    if not exist appserverset mkdir appserverset
    exit
)



if "%1"=="rpc" (
    call "%scriptDir%\stormi-checkworkbench.bat" 
    call "%scriptDir%\stormi-checkfirstnumber.bat" %2
    call "%scriptDir%\stormi-checkcapitalization.bat" %2
    call "%scriptDir%\stormi-checksuffix.bat" %2
    call "%scriptDir%\stormi-initrpc.bat" %2
    exit
)
if "%1"=="web" (
    call "%scriptDir%\stormi-checkworkbench.bat" 
    call "%scriptDir%\stormi-checkfirstnumber.bat" %2
    call "%scriptDir%\stormi-checkcapitalization.bat" %2
    call "%scriptDir%\stormi-checksuffix.bat" %2
    call "%scriptDir%\stormi-checkport.bat" %3
    call "%scriptDir%\stormi-initweb.bat" %2 %3
    exit
)


set "dir_name="

if "%1"=="gen" (
    for %%A in ("%cd%") do set "dir_name=%%~nxA"
    if "!dir_name!" == "protos" (
        if "%2" neq "" (
            echo current_dir is not web_dir
            exit
        )
        "%scriptDir%\stormi-gen.bat"
        exit
    )
    if "!dir_name!" == "rpcProtos" (
        if "%2" neq "" (
            echo current_dir is not web_dir
            exit
        )
        call "%scriptDir%\stormi-refresh.bat"
        exit
    )
    if "!dir_name!" == "web" (
        call "%scriptDir%\stormi-checkfirstnumber.bat" %2
        call "%scriptDir%\stormi-checkcapitalization.bat" %2
        call "%scriptDir%\stormi-router.bat" %2
        exit
    )

    echo only in protos, rpcProtos, web directory can generate codes.

    exit
)




if "%1"=="run" (
    for %%A in ("%cd%") do set "dir_name=%%~nxA"
    if "!dir_name!" == "protos" (
        go run .\RegisterAndStart\RegisterAndStart.go
        exit
    )
    if "!dir_name!" == "rpcProtos" (
        go run .\Test\Test.go
        exit
    )
    if "!dir_name!" == "web" (
        go run .\start\Start.go
        exit
    )
    if "!dir_name!" == "RegisterAndStart" (
        go run RegisterAndStart.go
        exit
    )
    if "!dir_name!" == "Test" (
        go run Test.go
        exit
    )
    if "!dir_name!" == "start" (
        go run Start.go
        exit
    )
    echo only run RegisterAndStart.go, Test.go, Start.go within current path.
    exit
)


endlocal






