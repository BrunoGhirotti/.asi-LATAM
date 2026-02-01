@ECHO OFF
CHCP 65001 >nul
CLS
SETLOCAL EnableExtensions EnableDelayedExpansion

SET SCRIPT_DIR=%~dp0

REM ##########################################
REM ## EDITE O CAMINHO ABAIXO SE NECESSÁRIO ##
REM ##########################################
SET TARGET_FOLDER=C:\Gravity\Ragnarok
SET TARGET_EXE=Ragexe.exe
REM ##########################################

SET UNPACKED_EXE=%TARGET_FOLDER%\unpacked_%TARGET_EXE%

ECHO #####################################################
ECHO ##                                                 ##
ECHO ##                 Gordão Programas                ##
ECHO ##               unpacker Ragexe.exe               ##
ECHO ##      Desenvolvido por: Bruno Costa - 2026       ##
ECHO ##                      v1.1                       ##
ECHO ##                                                 ##
ECHO #####################################################

if not exist "%TARGET_FOLDER%\%TARGET_EXE%" (
    ECHO.
    ECHO [ERRO] Arquivo nao encontrado:
    ECHO %TARGET_EXE%
    PAUSE
    exit /b 1
)

ECHO.
ECHO Executando unlicense...
ECHO.

cd %TARGET_FOLDER%
python -m unlicense "%TARGET_EXE%"

IF %ERRORLEVEL% NEQ 0 (
    ECHO.
    ECHO [ERRO] Falha ao executar unlicense.
    PAUSE
    EXIT /b 1
)

IF NOT EXIST "%UNPACKED_EXE%" (
    ECHO.
    ECHO [ERRO] Unpacked nao encontrado:
    ECHO %UNPACKED_EXE%
    PAUSE
    EXIT /b 1
)

ECHO.
ECHO Movendo executavel unpacked para a pasta do script...
ECHO.

MOVE /Y "%UNPACKED_EXE%" "%SCRIPT_DIR%" >nul

IF NOT EXIST "%SCRIPT_DIR%\unpacked_%TARGET_EXE%" (
    ECHO.
    ECHO [ERRO] Falha ao mover o executavel unpacked.
    PAUSE
    EXIT /b 1
)

COLOR 20
CLS
ECHO #####################################################
ECHO ##                                                 ##
ECHO ##               Processo finalizado               ##
ECHO ##      unpacked_Ragexe.exe salvo localmente       ##
ECHO ##                                                 ##
ECHO #####################################################
ECHO.
PAUSE