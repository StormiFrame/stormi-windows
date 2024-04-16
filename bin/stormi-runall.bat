@echo off

for /d %%A in (*) do (
    cd %%A
    for /d %%B in (*) do (
        if "%%B"=="web" (
            if exist "%%B\start\Start.go" (
                start /b go run "%%B\start\Start.go" > nul 2>&1
                echo %%A web server start ......
            )
        )
        if "%%B"=="server" (
            if exist "server\protos\RegisterAndStart\RegisterAndStart.go" (
                start /b go run "server\protos\RegisterAndStart\RegisterAndStart.go" > nul 2>&1
                echo %%A rpc server start ......
            )
        )
    )
    cd ..
)


:loop
set /p userInput="'x' to terminate all servers; '-' to run in the background: "
if "%userInput%"=="x" (
    stormi-killall
    exit
)
if "%userInput%"=="-" (
    exit
)
goto loop
