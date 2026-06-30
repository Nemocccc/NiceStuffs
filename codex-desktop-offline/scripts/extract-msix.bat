@echo off
setlocal enabledelayedexpansion
echo ---------------------------------------------------------------
echo  Codex Desktop - Offline Package Extractor
echo.
echo  Run this on a machine WHERE CODEX DESKTOP IS ALREADY INSTALLED.
echo ---------------------------------------------------------------
echo.

set "OUTDIR=%~dp0..\pkg"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo [1/3] Finding Codex Desktop installation...
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-AppxPackage -Name '*codex*' | Select-Object -ExpandProperty PackageFullName" 2^>nul') do set "PKG_FULL=%%a"

if "%PKG_FULL%"=="" (
    echo  FAIL: Codex Desktop not found. Install it via Microsoft Store first.
    pause
    exit /b 1
)
echo  Found: %PKG_FULL%

echo [2/3] Getting install location...
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "(Get-AppxPackage -Name '*codex*').InstallLocation" 2^>nul') do set "INSTALL_DIR=%%a"
echo  Location: %INSTALL_DIR%

if not exist "!INSTALL_DIR!" (
    echo  FAIL: Install directory not found
    pause
    exit /b 1
)

echo [3/3] Copying package files for offline deployment...
mkdir "%OUTDIR%\AppxPackage" 2>nul
xcopy /E /I /Y "!INSTALL_DIR!\*" "%OUTDIR%\AppxPackage\" >nul 2>&1
echo  Copied to %OUTDIR%\AppxPackage\
echo.
echo  Saving manifest...
powershell -NoProfile -Command "Get-AppxPackage -Name '*codex*' | Get-AppxPackageManifest" > "%OUTDIR%\AppxManifest.xml" 2>nul

echo.
echo ---------------------------------------------------------------
echo  Files extracted to pkg\AppxPackage\
echo.
echo  To deploy on intranet machine:
echo    powershell Add-AppxPackage -Path "pkg\AppxPackage\AppxManifest.xml"
echo.
echo  If license errors occur, try:
echo    Add-AppxProvisionedPackage -Online -SkipLicense -PackagePath "pkg\AppxPackage\"
echo ---------------------------------------------------------------
pause
