    if not exist "%CD%\appserverset" (
        mkdir "%CD%\appserverset"
    )
    if not exist %CD%\app.yaml (
        echo not have app.yaml in current path. please execute sotrmi init
        exit
    )
    for /f "tokens=1,* delims=:" %%a in ('findstr /C:"url:" "app.yaml"') do (
        set "url=%%b"
    )
    for /f "tokens=1,* delims=:" %%a in ('findstr /C:"password:" "app.yaml"') do (
        set "password=%%b"
    )
    if "%1"=="" (
        echo No second parameter provided.
        exit
    )

    if exist %CD%\%1 (
        echo Error: directory %1 exists
        exit
    )
    mkdir %CD%\%1
    xcopy "%scriptDir%\assets\StormiWeb\*" "%CD%\%1\" /e /i /y /q > nul
    xcopy "%CD%\appserverset\*" "%CD%\%1\server\rpcProtos" /e /i /y /q >> nul
    
    del %CD%\%1\app.yaml

    echo stormi: >> "%CD%\%1\app.yaml"
    echo     redis: >> "%CD%\%1\app.yaml"
    echo         url:!url!>> "%CD%\%1\app.yaml"
    echo         password:!password! >> "%CD%\%1\app.yaml"
    echo     server: >> "%CD%\%1\app.yaml"
    echo         name: %1 >> "%CD%\%1\app.yaml"
    echo         port: %2 >> "%CD%\%1\app.yaml"

    echo please enter: %CD%\%1\web
    call "%scriptDir%\stormi-init.bat" %1

    exit