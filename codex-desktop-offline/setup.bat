@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Admin rights required.
    pause
    exit /b 1
)

echo ---------------------------------------------------------------
echo  Codex Desktop Offline Installer
echo ---------------------------------------------------------------
echo.

if not exist "pkg\AppxPackage\AppxManifest.xml" (
    echo [MISS] pkg\AppxPackage\AppxManifest.xml not found.
    echo  Run scripts\extract-msix.bat on a machine where
    echo  Codex Desktop is already installed.
    pause
    exit /b 1
)

set "MANIFEST=%CD%\pkg\AppxPackage\AppxManifest.xml"
set "APPDIR=%CD%\pkg\AppxPackage"

echo [Mode] Extracted AppxPackage found
echo.

echo [1/5] Trying Add-AppxPackage -Register (manifest)...
powershell -Command "& {Add-AppxPackage -Register '%MANIFEST%' -ErrorAction SilentlyContinue}"
if %errorlevel% equ 0 (
    echo  [OK] Installed
    goto :verify
)
echo  [INFO] Register failed (code %errorlevel%)

echo [2/5] Trying Add-AppxPackage -Path (manifest)...
powershell -Command "& {Add-AppxPackage -Path '%MANIFEST%' -ErrorAction SilentlyContinue}"
if %errorlevel% equ 0 (
    echo  [OK] Installed
    goto :verify
)
echo  [INFO] Path install failed (code %errorlevel%)

echo [3/5] Installing certificate and retrying...
if exist "%APPDIR%\AppxMetadata\CodeIntegrity.cat" (
    powershell -Command "& {Import-Certificate -FilePath '%APPDIR%\AppxMetadata\CodeIntegrity.cat' -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -ErrorAction SilentlyContinue}"
    echo  [INFO] Certificate imported
)
powershell -Command "& {Add-AppxPackage -Path '%MANIFEST%' -ErrorAction SilentlyContinue}"
if %errorlevel% equ 0 (
    echo  [OK] Installed after certificate
    goto :verify
)

echo [4/5] Trying Add-AppxProvisionedPackage...
powershell -Command "& {Add-AppxProvisionedPackage -Online -PackagePath '%APPDIR%' -SkipLicense -ErrorAction SilentlyContinue}"
if %errorlevel% equ 0 (
    echo  [OK] Installed via provisioned package
    goto :verify
)

echo [5/5] Trying DISM offline provisioning...
powershell -Command "& {DISM /Online /Add-ProvisionedAppxPackage /PackagePath:'%APPDIR%' /SkipLicense 2>$null}"
if %errorlevel% equ 0 (
    echo  [OK] Installed via DISM
    goto :verify
)

echo.
echo ---------------------------------------------------------------
echo  FAILED. Possible solutions:
echo    1. Enable Developer Mode:
echo       Settings -^> Privacy & security -^> For developers
echo       Toggle ON "Developer Mode"  (reboot required)
echo    2. Re-run setup.bat
echo    3. If still fails, the package may need a different
echo       certificate chain. Try on the source machine:
echo       scripts\extract-msix.bat
echo ---------------------------------------------------------------
pause
exit /b 1

:verify
echo.
echo ---------------------------------------------------------------
echo  DONE. Codex Desktop should be in Start Menu.
echo ---------------------------------------------------------------
pause
