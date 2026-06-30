@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0.."

set NVM_VER=
set NODE_VER=
for /f "tokens=1,* delims==" %%a in (settings.ini) do (
    if /i "%%a"=="NVM_VER" set NVM_VER=%%b
    if /i "%%a"=="NODE_VER" set NODE_VER=%%b
)

if "%NODE_VER%"=="" (
    echo ERROR: settings.ini not found or missing NODE_VER
    pause
    exit /b 1
)

set NODE_ZIP=node-v%NODE_VER%-win-x64

echo ---------------------------------------------------------------
echo  Claude Code Offline Packer
echo  Downloads nvm, Node.js, and Claude Code for offline install.
echo  Run this on a machine WITH internet access.
echo ---------------------------------------------------------------
echo.

if exist "nvm\nvm.exe" (
    echo [SKIP] nvm already downloaded
) else (
    echo [1/3] Downloading nvm-windows...
    where curl >nul 2>&1
    if !errorlevel! equ 0 (
        curl -L --connect-timeout 30 -o nvm-tmp.zip "https://github.com/coreybutler/nvm-windows/releases/download/%NVM_VER%/nvm-noinstall.zip"
    ) else (
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; Invoke-WebRequest -Uri 'https://github.com/coreybutler/nvm-windows/releases/download/%NVM_VER%/nvm-noinstall.zip' -OutFile 'nvm-tmp.zip'"
    )
    if not exist "nvm-tmp.zip" (
        echo FAILED: Could not download nvm. Check internet connection.
        pause
        exit /b 1
    )
    powershell -Command "Expand-Archive -Force nvm-tmp.zip -DestinationPath nvm" >nul 2>&1
    del nvm-tmp.zip
    if exist "nvm\nvm.exe" (echo [OK]) else (echo FAILED && pause && exit /b 1)
)

if exist "node\%NODE_ZIP%\node.exe" (
    echo [SKIP] Node.js already downloaded
) else (
    echo [2/3] Downloading Node.js v%NODE_VER%...
    where curl >nul 2>&1
    if !errorlevel! equ 0 (
        curl -L --connect-timeout 30 -o node-tmp.zip "https://nodejs.org/dist/v%NODE_VER%/node-v%NODE_VER%-win-x64.zip"
    ) else (
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; Invoke-WebRequest -Uri 'https://nodejs.org/dist/v%NODE_VER%/node-v%NODE_VER%-win-x64.zip' -OutFile 'node-tmp.zip'"
    )
    if not exist "node-tmp.zip" (
        echo FAILED: Could not download Node.js. Check internet connection.
        pause
        exit /b 1
    )
    powershell -Command "Expand-Archive -Force node-tmp.zip -DestinationPath node" >nul 2>&1
    del node-tmp.zip
    if exist "node\%NODE_ZIP%\node.exe" (echo [OK]) else (echo FAILED && pause && exit /b 1)
)

if exist "claude-code-offline\node_modules\@anthropic-ai\claude-code\bin\claude.exe" (
    echo [SKIP] Claude Code already downloaded
) else (
    echo [3/3] Downloading Claude Code (requires npm, may take several minutes)...
    set PATH=%CD%\node\%NODE_ZIP%;%PATH%
    if not exist "claude-code-offline" mkdir claude-code-offline
    cd claude-code-offline
    call npm init -y >nul 2>&1
    call npm install @anthropic-ai/claude-code
    if !errorlevel! neq 0 (
        echo FAILED: npm install failed. Check internet or proxy settings.
        cd ..
        pause
        exit /b 1
    )
    if exist "package.json" del package.json >nul 2>&1
    if exist "package-lock.json" del package-lock.json >nul 2>&1
    call npm pack @anthropic-ai/claude-code >nul 2>&1
    cd ..
    if exist "claude-code-offline\node_modules\@anthropic-ai\claude-code\bin\claude.exe" (
        echo [OK]
    ) else (
        echo FAILED: claude.exe not found after npm install
        pause
        exit /b 1
    )
)

echo.
echo ---------------------------------------------------------------
echo  DOWNLOAD COMPLETE
echo.
echo  Total size:
dir /s /-c nvm node claude-code-offline 2>nul | find "File(s)"
echo.
echo  Copy this entire folder to a USB drive, then on the intranet
echo  machine right-click setup.bat -^> "Run as administrator"
echo ---------------------------------------------------------------
pause
