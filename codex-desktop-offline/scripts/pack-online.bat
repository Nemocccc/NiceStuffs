@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0.."

for /f "tokens=1,* delims==" %%a in (settings.ini) do (
    if /i "%%a"=="STORE_PRODUCT_ID" set PID=%%b
    if /i "%%a"=="DOWNLOAD_URL" set DLURL=%%b
)

echo ---------------------------------------------------------------
echo  Codex Desktop Offline Packer
echo  Downloads the Codex Desktop installer from Microsoft.
echo  Run this on a machine WITH internet access.
echo ---------------------------------------------------------------
echo.

if exist "pkg\CodexDesktopInstaller.exe" (
    echo [SKIP] Installer already downloaded
) else (
    echo [1/1] Downloading Codex Desktop...
    if not exist "pkg" mkdir pkg

    where curl >nul 2>&1
    if !errorlevel! equ 0 (
        curl -L --connect-timeout 30 -o pkg\CodexDesktopInstaller.exe "!DLURL!"
    ) else (
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; Invoke-WebRequest -Uri '!DLURL!' -OutFile 'pkg\CodexDesktopInstaller.exe'"
    )

    if exist "pkg\CodexDesktopInstaller.exe" (
        for %%f in ("pkg\CodexDesktopInstaller.exe") do set "SZ=%%~zf"
        echo  [OK] !SZ! bytes downloaded
        echo.
        echo  NOTE: This is a web installer (stub). The full app will be
        echo  downloaded on first run. For true offline install, run the
        echo  installer once on an internet machine^; the app will then
        echo  be available offline.
    ) else (
        echo FAILED
        pause
        exit /b 1
    )
)

echo.
echo ---------------------------------------------------------------
echo  DONE
echo.
echo  Run setup.bat as administrator on the target machine.
echo ---------------------------------------------------------------
pause
