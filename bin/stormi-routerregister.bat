set "temp=%1temp.txt"
if exist %temp% del %temp%


echo package register >> %temp%
echo. >> %temp%
echo import "Stormi/web/routers" >> "%temp%"
echo. >> "%temp%"
echo func Register^(^) ^{ >> %temp%

if not exist %1 exit

setlocal enabledelayedexpansion
set "str="
for /f "tokens=*" %%i in ('findstr /r "routers" "%1"' ) do (
    set "str=%%i"
    set "substring=!str:~0,8!"
    if "!substring!"=="routers." (
        if "!str!" neq "routers.%2Router()" echo     !str! >> %temp%
    )
)
endlocal

echo     routers.%2Router^(^)>> %temp%

echo ^} >> %temp%

del %1

rename %temp% RouterRegister.go