set "goFilePath=%1\ServerSet\ServerSet.go"

if exist "%goFilePath%" del %goFilePath%

set "folder=%1\ServerSet"
if not exist "%folder%" (
    mkdir "%folder%"
)
del %goFilePath% 2>nul
echo package ServerSet>>%goFilePath%
echo.>>%goFilePath%
echo import(>>%goFilePath%
echo     "Stormi/stormi">>%goFilePath%
echo     "time">>%goFilePath%
echo     "google.golang.org/grpc">>%goFilePath%
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo     "Stormi/server/rpcProtos/ProtoCode/%%~nF">>%goFilePath%
    )
)
echo )>>%goFilePath%
echo.>>%goFilePath%
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
            echo var %%~nFCall %%~nF.%%~nFClient >> %goFilePath%
        )
)
echo.>>%goFilePath%
echo func init() ^{ >> %goFilePath%

for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo 	var %%~nFConnNew *grpc.ClientConn>> %goFilePath%
        echo 	%%~nFConnNew = stormi.GetCloudConn("%%~nF"^)>> %goFilePath%
        echo 	%%~nFCall = %%~nF.New%%~nFClient(%%~nFConnNew^) >> %goFilePath%
        echo 	var %%~nFConnOld *grpc.ClientConn>> %goFilePath%
        echo 	%%~nFConnOld = %%~nFConnNew>> %goFilePath%
    )
)
echo     go func() ^{ >> %goFilePath%
echo 		for ^{ >> %goFilePath%
echo 		    time.Sleep(3 * time.Second) >> %goFilePath%
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo 			%%~nFConnNew = stormi.GetCloudConn("%%~nF"^)>> %goFilePath%
    )
)
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo 			%%~nFCall = %%~nF.New%%~nFClient(%%~nFConnNew^) >> %goFilePath%
    )
)
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo 			%%~nFConnOld.Close(^)>> %goFilePath%
    )
)
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo 			%%~nFConnOld = %%~nFConnNew>> %goFilePath%
    )
)
echo 		} >> %goFilePath%
echo 	}() >> %goFilePath%
echo ^}>> %goFilePath%