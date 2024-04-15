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
echo     var CloudServerName string >> %goFilePath%
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo 	CloudServerName = "%%~nF">> %goFilePath%
        echo 	%%~nFCall = %%~nF.New%%~nFClient(stormi.GetCloudConn(CloudServerName^)^) >> %goFilePath%
    )
)
echo     go func() ^{ >> %goFilePath%
echo 		for ^{ >> %goFilePath%
for %%F in ("%1\*.proto") do (
    for /f "tokens=1 delims=." %%S in ("%%~nF") do (
        echo 			CloudServerName = "%%~nF">> %goFilePath%
        echo 			%%~nFCall = %%~nF.New%%~nFClient(stormi.GetCloudConn(CloudServerName^)^) >> %goFilePath%
    )
)
echo 		    time.Sleep(3 * time.Second) >> %goFilePath%
echo 		} >> %goFilePath%
echo 	}() >> %goFilePath%
echo ^}>> %goFilePath%