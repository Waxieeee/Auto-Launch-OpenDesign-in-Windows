@echo off
title OpenDesign Launcher
echo =========================
echo Starting OpenDesign...
echo =========================

:: ── CONFIGURE THESE ──────────────────────────────────────────────────────────
:: Path to your OpenDesign project folder
set "PROJECT_DIR=C:\Users\B3ast\open-design"

:: Path to Brave Browser executable (check both Program Files locations)
set "BRAVE=C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
set "BRAVE_ALT=C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"

:: Node version to use (via nvm)
set "NODE_VERSION=24"
:: ─────────────────────────────────────────────────────────────────────────────

cd /d "%PROJECT_DIR%"
echo Current directory:
cd

echo Switching Node version...
call nvm use %NODE_VERSION%
echo Node version:
node -v

echo Checking pnpm...
where pnpm

:: ── Set up a temp log file to capture server output ──────────────────────────
set "LOGFILE=%TEMP%\opendesign_server.log"
if exist "%LOGFILE%" del "%LOGFILE%"

:: ── Launch server in a NEW window, stdout+stderr piped to the log file ────────
echo.
echo Starting server (output captured to: %LOGFILE%)...
start "OpenDesign Server" cmd /c "pnpm exec tools-dev run web > "%LOGFILE%" 2>&1"

:: ── Poll the log file until a 127.0.0.1:<port> URL appears ───────────────────
echo Waiting for server URL
:WAIT_LOOP
timeout /t 2 /nobreak >nul
if not exist "%LOGFILE%" goto WAIT_LOOP

powershell -NoProfile -Command ^
  "if (Select-String -Path '%LOGFILE%' -Pattern 'http://127\.0\.0\.1:\d+' -Quiet) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    <nul set /p "=."
    goto WAIT_LOOP
)

:: ── Extract the full URL (e.g. http://127.0.0.1:52341/) ──────────────────────
for /f "usebackq delims=" %%U in (`powershell -NoProfile -Command ^
  "(Select-String -Path '%LOGFILE%' -Pattern 'http://127\.0\.0\.1:\d+[^ ]*').Matches[0].Value"`) do (
    set "SERVER_URL=%%U"
)

echo.
echo ============================================
echo  Server detected at: %SERVER_URL%
echo ============================================
echo Opening Brave Browser...

:: ── Open Brave, fallback to default browser ───────────────────────────────────
if exist "%BRAVE%" (
    start "" "%BRAVE%" "%SERVER_URL%"
) else if exist "%BRAVE_ALT%" (
    start "" "%BRAVE_ALT%" "%SERVER_URL%"
) else (
    echo Brave not found. Opening with default browser instead...
    start "" "%SERVER_URL%"
)

echo.
echo Server log is live at: %LOGFILE%
echo Close the "OpenDesign Server" window to stop the server.
pause
