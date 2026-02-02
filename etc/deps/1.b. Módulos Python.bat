@ECHO OFF
CHCP 65001 >nul
CLS
SETLOCAL EnableExtensions EnableDelayedExpansion

ECHO #####################################################
ECHO ##                                                 ##
ECHO ##        Instalador de Dependencias Python        ##
ECHO ##      Desenvolvido por: Bruno Costa - 2026       ##
ECHO ##                     v1.1                        ##
ECHO ##                                                 ##
ECHO #####################################################
ECHO.

python --version >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (
    CLS
    COLOR 40
    ECHO #####################################################
    ECHO ##                                                 ##
    ECHO ##   Python 3.11.9 nao esta instalado no sistema   ##
    ECHO ##                                                 ##
    ECHO #####################################################
    ECHO.
    PAUSE
    EXIT /B 1
)

FOR /f "delims=" %%v in ('python.exe --version 2^>^&1') DO (
    IF "%%v"=="Python 3.11.9" (
        ECHO Versao correta do Python encontrada: %%v
    ) ELSE (
        CLS
        COLOR 40
        ECHO #####################################################
        ECHO ##                                                 ##
        ECHO ##  Python 3.11.9 nao esta instalado no sistema    ##
        ECHO ##                                                 ##
        ECHO #####################################################
        ECHO.
        ECHO Versao encontrada: %%v
        ECHO A versao instalada nao e compativel com os modulos necessarios.
        PAUSE
        EXIT /B 1
    )
)

python -m pip --version >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (
    ECHO Instalando pip...
    python -m ensurepip
)
ECHO.
ECHO Atualizando pip...

python -m pip install --upgrade pip

python -c "import pefile" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO pefile ja esta instalado.
) ELSE (
    ECHO Instalando pefile...
    python -m pip install pefile
    python -c "import pefile; print('pefile instalado com sucesso')"
)

python -c "import unlicense" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO unlicense ja esta instalado.
) ELSE (
    ECHO Instalando unlicense...
    python -m pip install git+https://github.com/Brunnexo/unlicense.git
    python -c "import unlicense; print('unlicense instalado com sucesso')"
)

COLOR 20
CLS
ECHO #####################################################
ECHO ##                                                 ##
ECHO ##      Dependencias instaladas com sucesso:       ##
python -c "import pefile; print('##                  pefile                         ##')"
python -c "import unlicense; print('##                 unlicense                       ##')"
ECHO ##                                                 ##
ECHO #####################################################
ECHO.
PAUSE