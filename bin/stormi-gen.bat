@echo off

setlocal enabledelayedexpansion

chcp 65001 > nul

set "error_message=Error: please make sure file name,package name,service name, response and request prefix name are same."

for %%i in (*.proto) do (
        set "filename=%%~ni"
        set "last_six_chars=!filename:~-6!"

        if  "!last_six_chars!"=="Server" (
            set "error_message=Error: file name can not end with Server"
            echo !error_message! file: %%i
            exit /b 1
        )
        if  "!last_six_chars!"=="server" (
                    set "error_message=Error: file name can not end with server"
                    echo !error_message! file: %%i
                    exit /b 1
                )


        findstr /n /i "option go_package = \".;%%~ni\";" "%%i" >> temp_proto_check.tmp
        findstr /n /i "service %%~ni{" "%%i" >> temp_proto_check.tmp
        findstr /n /i "message %%~niRequest{" "%%i" >> temp_proto_check.tmp
        findstr /n /i "message %%~niResponse{" "%%i" >> temp_proto_check.tmp

        findstr /c:"option go_package = \".;%%~ni\";" temp_proto_check.tmp > nul || (
            echo %error_message% File: %%i
            echo please change to: option go_package = ".;%%~ni";
            del temp_proto_check.tmp
            exit /b 1
        )
        findstr /c:"service %%~ni{" temp_proto_check.tmp > nul || (
            echo %error_message% File: %%i
            echo please change to: service %%~ni
            del temp_proto_check.tmp
            exit /b 1
        )
        findstr /c:"message %%~niRequest{" temp_proto_check.tmp > nul || (
            echo %error_message% File: %%i
            echo please change to: message %%~niRequest
            del temp_proto_check.tmp
            exit /b 1
        )
        findstr /c:"message %%~niResponse{" temp_proto_check.tmp > nul || (
            echo %error_message% File: %%i
            echo please change to: message %%~niResponse
            del temp_proto_check.tmp
            exit /b 1
        )
        del temp_proto_check.tmp
)

set "folder=Impl"

if not exist "%folder%" (
    mkdir "%folder%"
)

for %%i in (*.proto) do (
    set filename=%%~ni
    set Impl_filename=!filename!Impl.go

    if not exist Impl\!Impl_filename! (
        (
                echo package Impl
                echo import ^(
                echo    "Stormi/server/protos/ProtoCode/!filename!"
                echo    "context"
                echo    "google.golang.org/grpc/codes"
                echo    "google.golang.org/grpc/status"
                echo ^)
                echo type !filename!Impl struct ^{
                echo    !filename!.Unimplemented!filename!Server
                echo ^}
                for /f "tokens=*" %%j in ('type "%%i" ^| findstr /r /i "^ *rpc "') do (
                        set "line=%%j"
                        set "first_five=!line:~0,3!"
                        if /i "!first_five!"=="rpc" (
                            set "line=!line:rpc=!"
                            for /f "tokens=* delims= " %%a in ("!line!") do set "line=%%a"
                            for /f "tokens=1 delims=(" %%a in ("!line!") do (
                                set "result=%%a"
                                echo func ^(s *!filename!Impl^)!result!^(ctx context.Context, req *!filename!.!filename!Request^) ^(*!filename!.!filename!Response, error^) ^{
                                                echo    return nil, status.Errorf^(codes.Unimplemented, "method !filename!Impl not Implemented"^)
                                                echo ^}
                            )
                        )
                    )
            ) > Impl\!Impl_filename!
    )
    set foldername=ProtoCode\!filename!

    if not exist "!foldername!" (
        mkdir "!foldername!"
    )

    protoc --go_out="!foldername!" "%%i"
    protoc --go-grpc_out="!foldername!" "%%i"
)

endlocal

for /f "delims=" %%A in ('cd') do set "currentPath=%%A"
set "goFilePath=RegisterAndStart\RegisterAndStart.go"

del %goFilePath% 2>nul

set "folder=RegisterAndStart"

if not exist "%folder%" (
    mkdir "%folder%"
)

echo package main>>%goFilePath%
echo.>>%goFilePath%
echo import(>>%goFilePath%
echo     "Stormi/stormi">>%goFilePath%
echo     "Stormi/server/protos/Impl">>%goFilePath%
for %%F in ("%currentPath%\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo     "Stormi/server/protos/ProtoCode/%%~nF">>%goFilePath%
    )
)
echo )>>%goFilePath%
echo.>>%goFilePath%

echo func main() ^{ >> %goFilePath%
echo     rpc := stormi.GetStormiRpc()>> %goFilePath%

for /d %%a in (ProtoCode/*) do echo     %%a.Register%%aServer(rpc, ^&Impl.%%aImpl^{^}^) >> %goFilePath%
for /d %%a in (ProtoCode/*) do echo     stormi.RegisterWithName^("%%a"^) >> %goFilePath%


echo     stormi.StartServer()>> %goFilePath%
echo ^}>> %goFilePath%

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
set "workbenchpath=%output:~0,-1%"

if not exist "%workbenchpath%\appserverset" mkdir "%workbenchpath%\appserverset"

copy "*.proto" "%workbenchpath%\appserverset" > nul

