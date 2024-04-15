set "filename=%1"
set "last_six_chars=%filename:~-6%"
set "error_message=Error: file name can not end with Server"
if  "%last_six_chars%"=="Server" (
    echo %error_message% 
    exit
)
set "error_message=Error: file name can not end with server"
if  "%last_six_chars%"=="server" (
    echo %error_message%
    exit
)