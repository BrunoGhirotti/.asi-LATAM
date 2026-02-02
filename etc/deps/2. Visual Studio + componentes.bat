@ECHO OFF
CHCP 65001 >nul
CLS
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "ROOT=%~dp0"
SET "VS_DIR=%ROOT%vs"

ECHO #####################################################
ECHO ##                                                 ##
ECHO ##     Instalador Visual Studio Community 2026     ##
ECHO ##              MSBuild + SDK Windows              ##
ECHO ##       Desenvolvido por: Bruno Costa - 2026      ##
ECHO ##                                                 ##
ECHO #####################################################

IF NOT EXIST "%VS_DIR%\vs_Community.exe" (
    ECHO ERRO: vs_Community.exe nao encontrado em "%VS_DIR%"!
    PAUSE
    EXIT /b 1
)

IF NOT EXIST "%VS_DIR%\vsconfig.json" (
    ECHO ERRO: vsconfig.json nao encontrado em "%VS_DIR%"!
    PAUSE
    EXIT /b 1
)

ECHO Iniciando instalacao do Visual Studio...
ECHO Isso pode levar varios minutos.
ECHO.

"%VS_DIR%\vs_Community.exe" ^
 --quiet ^
 --wait ^
 --norestart ^
 --config "%VS_DIR%\vsconfig.json" ^
 --includeRecommended

SET "VS_ERROR=%ERRORLEVEL%"
IF %VS_ERROR% NEQ 0 (
    ECHO.
    ECHO ERRO: A instalacao falhou. Codigo: %VS_ERROR%
    PAUSE
    EXIT /b %VS_ERROR%
)


COLOR 20
CLS
ECHO #####################################################
ECHO ##                                                 ##
ECHO ##         Instalacao concluida com sucesso        ##
ECHO ##                                                 ##
ECHO #####################################################
ECHO.
PAUSE