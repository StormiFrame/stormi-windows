@echo off

set "routerPath=%CD%\routers\%1Router.go"
set "implPath=%CD%\impl\%1RouterImpl\%1RouterImpl.go"

if exist "%routerPath%" (
    echo %routerPath% exists
    exit
)
if exist "%implPath%" (
    echo %implPath% exists
    exit 
)

rem 如果目录不存在，则创建目录
if not exist "%CD%\routers" mkdir "%CD%\routers"
if not exist "%CD%\impl\%1RouterImpl" mkdir "%CD%\impl\%1RouterImpl"

rem 生成路由文件内容
echo package routers  >> "%routerPath%"
echo import (  >> "%routerPath%"
echo     "Stormi/stormi"  >> "%routerPath%"
echo     %1RouterImpl "Stormi/web/impl/%1RouterImpl"  >> "%routerPath%"
echo )  >> "%routerPath%"
echo.  >> "%routerPath%"
echo func %1Router() {  >> "%routerPath%"
echo     r := stormi.GetEngine()  >> "%routerPath%"
echo.  >> "%routerPath%"
echo     router := r.Group("/%1")  >> "%routerPath%"
echo     {  >> "%routerPath%"
echo         router.GET("/Get", %1RouterImpl.%1Get)  >> "%routerPath%"
echo         router.PUT("/Put", %1RouterImpl.%1Put)  >> "%routerPath%"
echo         router.POST("/Post", %1RouterImpl.%1Post)  >> "%routerPath%"
echo         router.DELETE("/Delete", %1RouterImpl.%1Delete)  >> "%routerPath%"
echo     }  >> "%routerPath%"
echo }  >> "%routerPath%"

rem 生成实现文件内容
echo package %1RouterImpl  >> "%implPath%"
echo.  >> "%implPath%"
echo import ( >> "%implPath%"
echo     "net/http" >> "%implPath%"
echo.  >> "%implPath%"
echo     "github.com/gin-gonic/gin"  >> "%implPath%"
echo ) >> "%implPath%"
echo.  >> "%implPath%"
echo func %1Get(ctx *gin.Context) {  >> "%implPath%"
echo     ctx.String(http.StatusOK, "%1 Get") >> "%implPath%"
echo } >> "%implPath%"
echo.  >> "%implPath%"
echo func %1Put(ctx *gin.Context) { >> "%implPath%"
echo     ctx.String(http.StatusOK, "%1 Put") >> "%implPath%"
echo } >> "%implPath%"
echo.  >> "%implPath%"
echo func %1Post(ctx *gin.Context) { >> "%implPath%"
echo     ctx.String(http.StatusOK, "%1 Post") >> "%implPath%"
echo } >> "%implPath%"
echo.  >> "%implPath%"
echo func %1Delete(ctx *gin.Context) { >> "%implPath%"
echo     ctx.String(http.StatusOK, "%1 Delete") >> "%implPath%"
echo } >> "%implPath%"


setlocal enabledelayedexpansion
set "startPath=%CD%\start\Start.go"

if not exist %CD%\start mkdir %CD%\start

if not exist %startPath% (
    echo package main >> %startPath%
    echo.  >> %startPath%
    echo import ^( >> %startPath%
    echo    "Stormi/stormi" >> %startPath%
    echo  	register "Stormi/web/routers/Register" >> %startPath%
    echo ^)  >> %startPath%
    echo.  >> %startPath%
    echo func main^(^) ^{ >> %startPath%
    echo 	register.Register^(^) >> %startPath%
    echo 	stormi.GetEngine^(^).Run^(":" + stormi.GetPort^(^)^) >> %startPath%
    echo ^} >> %startPath%
)
endlocal

set "registerPath=%CD%\routers\Register\RouterRegister.go"

if not exist %CD%\routers\Register mkdir %CD%\routers\Register

if not exist "%registerPath%" (
    echo package register >> "%registerPath%"
    echo. >> "%registerPath%"
    echo import "Stormi/web/routers" >> "%registerPath%"
    echo. >> "%registerPath%"
    echo func Register^(^) ^{ >> "%registerPath%"
    echo ^} >> "%registerPath%"

)


call "%scriptDir%\stormi-routerregister.bat" "%registerPath%" %1

