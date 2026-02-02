@ECHO OFF
CHCP 65001 >nul
CLS
SETLOCAL EnableExtensions EnableDelayedExpansion

SET PYTHON_VERSION=3.11.9
SET PYTHON_EXE=python-3.11.9.exe
SET PYTHON_URL=https://www.python.org/ftp/python/3.11.9/python-3.11.9.exe
SET PYTHON_DIR=%ProgramFiles(x86)%\Python311-32

ECHO #####################################################
ECHO ##                                                 ##
ECHO ##         Instalador Python %PYTHON_VERSION% x86            ##
ECHO ##       Desenvolvido por: Bruno Costa - 2026      ##
ECHO ##                     v1.1                        ##
ECHO ##                                                 ##
ECHO #####################################################
ECHO.

python --version >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    CLS

    ECHO #####################################################
    ECHO ##                                                 ##
    ECHO ## A seguinte versao ja esta instalada no sistema: ##
    FOR /f "delims=" %%v in ('python.exe --version 2^>^&1') DO (
        ECHO ##                 %%v                   ##
        IF "%%v"=="Python %PYTHON_VERSION%" (
            COLOR 20
            ECHO ##           Esta versao e a desejada              ##
        ) ELSE (
            COLOR 60
            ECHO ##    Esta versao nao coincide com a desejada      ##
            ECHO ##   Por favor, desinstale qualquer outra versao   ##
        )
    )
    ECHO ##                                                 ##
    ECHO #####################################################
    ECHO.
    PAUSE
    EXIT /B 0
)

ECHO.
ECHO Baixando Python %PYTHON_VERSION% (32 bits)...
ECHO.

powershell -Command ^
 "Try { Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%PYTHON_EXE%' -UseBasicParsing } Catch { Exit 1 }"

IF NOT EXIST "%PYTHON_EXE%" (
    COLOR 40
    ECHO [ERRO] Falha ao baixar o Python.
    PAUSE
    EXIT /B 1
)

ECHO Instalando Python %PYTHON_VERSION%...
ECHO.

"%PYTHON_EXE%" /quiet ^
 InstallAllUsers=1 ^
 PrependPath=1 ^
 Include_test=0

IF %ERRORLEVEL% NEQ 0 (
    COLOR 40
    ECHO [ERRO] Falha na instalacao do Python.
    PAUSE
    EXIT /B 1
)

COLOR 20
CLS
ECHO #####################################################
ECHO ##                                                 ##
FOR /f "delims=" %%v in ('"%PYTHON_DIR%\python.exe" --version 2^>^&1') DO (
    ECHO ##       %%v instalado com sucesso       ##
)
ECHO ##                                                 ##
ECHO #####################################################
ECHO.
PAUSE