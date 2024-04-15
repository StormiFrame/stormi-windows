@echo off
setlocal enabledelayedexpansion

if "%1" == "" (
    echo no third parameter provided
    exit
)

set "input=%1"



if "%input:~1,1%" == "" (
    echo port invalid must be 8000-9999
    exit
) 
if "%input:~2,1%" == "" (
    echo port invalid must be 8000-9999
    exit
) 
if "%input:~3,1%" == "" (
    echo port invalid must be 8000-9999 
    exit
)
if "%input:~4,1%" neq "" (
    echo port invalid must be 8000-9999 
    exit
)

call "%~dp0\stormi-checknumber.bat" %input:~0,1%
call "%~dp0\stormi-checknumber.bat" %input:~1,1%
call "%~dp0\stormi-checknumber.bat" %input:~2,1%
call "%~dp0\stormi-checknumber.bat" %input:~3,1%

if "%input:~0,1%" neq "8" (
    if "%input:~0,1%" neq "9" (
        echo port invalid must be 8000-9999 
        exit
    )
)
endlocal