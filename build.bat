@ECHO off
setlocal EnableExtensions EnableDelayedExpansion

SET SOLUTION=GordOPK.slnx
SET CONFIG=Release
SET PLATFORM=x86
SET OUTPUT=Release\GordOPK.asi
SET FINAL=GordOPK.asi

ECHO ========================================
ECHO    Build GordOPK.asi - Visual Studio
ECHO ========================================
ECHO.

SET VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe

if not exist "%VSWHERE%" (
    ECHO ERRO: vswhere.exe nao encontrado.
    ECHO Instale o Visual Studio 2017 ou superior.
    goto :fail
)

:: ===============================
:: Encontrar VS mais recente com MSBuild
:: ===============================
for /f "usebackq delims=" %%I in (`
    "%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
`) do SET VSINSTALL=%%I

if not defined VSINSTALL (
    ECHO ERRO: Nenhuma instalacao valida do Visual Studio foi encontrada.
    goto :fail
)

SET VSDEV="%VSINSTALL%\Common7\Tools\VsDevCmd.bat"

if not exist %VSDEV% (
    ECHO ERRO: VsDevCmd.bat nao encontrado em:
    ECHO %VSDEV%
    goto :fail
)

ECHO Visual Studio encontrado em:
ECHO %VSINSTALL%
ECHO.

:: ===============================
:: Inicializar ambiente VS
:: ===============================
call %VSDEV% >nul 2>&1
if errorlevel 1 (
    ECHO ERRO ao configurar ambiente do Visual Studio.
    goto :fail
)

:: ===============================
:: Limpeza
:: ===============================
ECHO Limpando arquivos anteriores...
del /f /q %FINAL% >nul 2>&1
del /f /q %OUTPUT% >nul 2>&1

:: ===============================
:: Build
:: ===============================
ECHO Compilando com MSBuild...
msbuild %SOLUTION% /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /verbosity:minimal
if errorlevel 1 goto :fail

:: ===============================
:: Verificação final
:: ===============================
if not exist %OUTPUT% (
    ECHO Build finalizado, mas recv.asi nao foi encontrado.
    goto :fail
)

copy /y %OUTPUT% %FINAL% >nul

if exist "GordOPK" rmdir /s /q "GordOPK"
if exist "Release" rmdir /s /q "Release"


COLOR 20
ECHO.
ECHO ========================================
ECHO     COMPILACAO CONCLUIDA COM SUCESSO!
ECHO ========================================
dir %FINAL%
goto :end

:fail
COLOR 04
ECHO.
ECHO ========================================
ECHO          ERRO NA COMPILACAO!
ECHO ========================================
ECHO Verifique as mensagens acima.

:end
ECHO.
pause
endlocal
