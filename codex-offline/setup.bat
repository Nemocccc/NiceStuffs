@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0" || (echo [ERROR] Cannot access setup dir & pause & exit /b 1)

reg query "HKU\S-1-5-19" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Admin rights required. Right-click setup.bat -^> "Run as administrator"
    pause & exit /b 1
)

if not exist "settings.ini" (echo [ERROR] settings.ini missing & pause & exit /b 1)

set NVM_VER=
set NODE_VER=
set CLI_VER=
for /f "tokens=1,* delims==" %%a in (settings.ini) do (
    if /i "%%a"=="NVM_VER" set NVM_VER=%%b
    if /i "%%a"=="NODE_VER" set NODE_VER=%%b
    if /i "%%a"=="CODEX_VER" set CLI_VER=%%b
)
if not defined NODE_VER (echo [ERROR] settings.ini invalid & pause & exit /b 1)

set NVM_DIR=%USERPROFILE%\.nvm
set CLI_DIR=%USERPROFILE%\codex
set NODE_ZIP=node-v%NODE_VER%-win-x64
set PKG_CODEX=codex-offline\node_modules\@openai\codex
set SRC_NODE=node\%NODE_ZIP%

echo.
echo === Codex CLI Offline Installer ===
echo.
echo [1/5] Checking offline files...

set MISS=0
if not exist "nvm\nvm.exe"                       (echo  [MISS] nvm\nvm.exe                       & set MISS=1)
if not exist "%SRC_NODE%\node.exe"               (echo  [MISS] %SRC_NODE%\node.exe               & set MISS=1)
if not exist "%PKG_CODEX%\bin\codex.js"          (echo  [MISS] codex.js                          & set MISS=1)
if %MISS% equ 1 (echo. & echo Run scripts\pack-online.bat first & pause & exit /b 1)

echo  [OK] all files present
echo.

echo [2/5] Installing nvm-windows...
if not exist "%NVM_DIR%" mkdir "%NVM_DIR%"
xcopy /E /I /Y "nvm\*" "%NVM_DIR%\" >nul 2>&1
if %errorlevel% neq 0 (echo [FAIL] xcopy nvm & pause & exit /b 1)
> "%NVM_DIR%\settings.txt" (echo root: %NVM_DIR% & echo arch: x64 & echo proxy: none)
echo  [OK]
echo.

echo [3/5] Installing Node.js v%NODE_VER%...
if not exist "%NVM_DIR%\nodejs" mkdir "%NVM_DIR%\nodejs"
xcopy /E /I /Y "%SRC_NODE%\*" "%NVM_DIR%\nodejs\" >nul 2>&1
if %errorlevel% neq 0 (echo [FAIL] xcopy Node.js & pause & exit /b 1)
set PATH=%NVM_DIR%\nodejs;%PATH%
for /f "tokens=*" %%a in ('node --version 2^>nul') do set NV=%%a
echo  [OK] node %NV%
echo.

echo [4/5] Installing Codex CLI v%CLI_VER%...
if not exist "%CLI_DIR%" mkdir "%CLI_DIR%"
xcopy /E /I /Y "%PKG_CODEX%\*" "%CLI_DIR%\" >nul 2>&1
if %errorlevel% neq 0 (echo [FAIL] xcopy Codex & pause & exit /b 1)
if not exist "%CLI_DIR%\bin\codex.js" (echo [FAIL] codex.js missing after copy & pause & exit /b 1)

> "%NVM_DIR%\codex.cmd" (
    echo @echo off
    echo set "PATH=%%USERPROFILE%%\.nvm\nodejs;%%PATH%%"
    echo node "%%USERPROFILE%%\codex\bin\codex.js" %%*
)
echo  [OK] codex.cmd created
echo.

echo [5/5] Setting environment variables...
for /f "skip=2 tokens=3*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "UP=%%a %%b"
if not defined UP set "UP=%PATH%"
echo "%UP%" | findstr /I /C:"%NVM_DIR%" >nul 2>&1
if errorlevel 1 (
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%NVM_DIR%;%NVM_DIR%\nodejs;%UP%" /f >nul 2>&1
    echo  [OK] PATH updated
) else (echo  [OK] PATH already set)
echo.
echo === DONE ===
echo.
echo Close this window, open a new Command Prompt, then run:
echo   codex --version
echo.
pause
