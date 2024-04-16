if "%1"=="version" goto :end
if "%1"=="init" goto :end
if "%1"=="rpc" goto :end
if "%1"=="web" goto :end
if "%1"=="gen" goto :end
if "%1"=="run" goto :end
if "%1"=="x" goto :end
if "%1"=="run-" goto :end
echo invalid command
exit
:end 