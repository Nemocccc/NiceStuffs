@echo off
setlocal
echo ---------------------------------------------------------------
echo  Codex CLI Post-Install Verification
echo ---------------------------------------------------------------
echo.
set ERR=0

echo [1/5] Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%a in ('node --version') do echo    node %%a
) else (
    echo    FAIL - node not found
    set ERR=1
)

echo [2/5] npm...
where npm >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%a in ('npm --version') do echo    npm v%%a
) else (
    echo    FAIL - npm not found
    set ERR=1
)

echo [3/5] Codex CLI...
where codex >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%a in ('codex --version 2^>nul') do echo    %%a
) else (
    echo    FAIL - codex not found
    echo    (check %%USERPROFILE%%\.nvm\codex.cmd)
    set ERR=1
)

echo [4/5] OPENAI_BASE_URL...
reg query "HKCU\Environment" /v OPENAI_BASE_URL >nul 2>&1
if %errorlevel% equ 0 (
    for /f "skip=2 tokens=3*" %%a in ('reg query "HKCU\Environment" /v OPENAI_BASE_URL') do echo    %%a
) else (
    echo    NOT SET
    set ERR=1
)

echo [5/5] PATH...
echo %PATH% | findstr /C:"\.nvm" >nul 2>&1
if %errorlevel% equ 0 (
    echo    PATH includes %%USERPROFILE%%\.nvm
) else (
    echo    WARNING - PATH missing .nvm - restart terminal
)

echo.
if %ERR% equ 0 (
    echo ALL CHECKS PASSED
) else (
    echo SOME CHECKS FAILED - re-run setup.bat as administrator
)
pause
