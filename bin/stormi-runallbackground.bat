@echo off

for /d %%A in (*) do (
    cd %%A
    for /d %%B in (*) do (
        if "%%B"=="web" (
            if exist "%%B\start\Start.go" (
                start /b "" go run "%%B\start\Start.go" > nul 2>&1
                echo %%A web server start ......
            )
        )
        if "%%B"=="server" (
            if exist "server\protos\RegisterAndStart\RegisterAndStart.go" (
                start "" /b /min go run "server\protos\RegisterAndStart\RegisterAndStart.go" > nul 2>&1
                echo %%A rpc server start ......
            )
        )
    )
    cd ..
)
