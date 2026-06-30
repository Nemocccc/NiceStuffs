@echo off
setlocal
echo ---------------------------------------------------------------
echo  Codex Desktop Post-Install Verification
echo ---------------------------------------------------------------
echo.

echo [1/3] Checking AppxPackage...
powershell -Command "Get-AppxPackage -Name '*codex*' | Select-Object Name, Version" 2>nul
if %errorlevel% neq 0 (
    echo  FAIL - Codex Desktop not found in AppxPackages
) else (
    echo  OK
)

echo.
echo [2/3] Checking Start Menu shortcut...
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Codex.lnk" (
    echo  OK - Start Menu shortcut found
) else (
    echo  WARN - No Start Menu shortcut (may be named differently)
)

echo.
echo [3/3] Checking Program Files...
if exist "%ProgramFiles%\WindowsApps\*Codex*" (
    echo  OK - Files found in WindowsApps
) else (
    echo  WARN - Not found in WindowsApps (may be installed elsewhere)
)

echo.
echo ---------------------------------------------------------------
echo  To launch: search for "Codex" in Start Menu
echo  To uninstall: Settings ^| Apps ^| Codex
echo ---------------------------------------------------------------
pause
