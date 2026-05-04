@echo off
title OpenDesign Launcher
echo =========================
echo Starting OpenDesign...
echo =========================
cd /d C:\Users\B3ast\open-design
echo Current directory:
cd
echo Switching Node version...
call nvm use 24
echo Node version:
node -v

:: ── Set up log files ──────────────────────────────────────────────────────────
set "DAEMON_LOG=%TEMP%\opendesign_daemon.log"
set "WEB_LOG=%TEMP%\opendesign_web.log"
if exist "%DAEMON_LOG%" del "%DAEMON_LOG%"
if exist "%WEB_LOG%"    del "%WEB_LOG%"

:: ── Launch daemon in a new window, piped to log ───────────────────────────────
echo.
echo Starting daemon...
start "OD Daemon" cmd /c "cd /d C:\Users\B3ast\open-design\apps\daemon && pnpm dev > "%DAEMON_LOG%" 2>&1"

:: ── Wait for daemon to be ready ───────────────────────────────────────────────
echo Waiting for daemon...
:DAEMON_LOOP
timeout /t 2 /nobreak >nul
if not exist "%DAEMON_LOG%" goto DAEMON_LOOP
powershell -NoProfile -Command ^
  "if (Select-String -Path '%DAEMON_LOG%' -Pattern 'daemon listening on' -Quiet) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    <nul set /p "=."
    goto DAEMON_LOOP
)
echo.
echo Daemon is ready.

:: ── Launch web in a new window, piped to log ─────────────────────────────────
echo Starting web server...
start "OD Web" cmd /c "cd /d C:\Users\B3ast\open-design\apps\web && pnpm dev > "%WEB_LOG%" 2>&1"

:: ── Wait for web to expose localhost URL ──────────────────────────────────────
echo Waiting for web server URL...
:WEB_LOOP
timeout /t 2 /nobreak >nul
if not exist "%WEB_LOG%" goto WEB_LOOP
powershell -NoProfile -Command ^
  "if (Select-String -Path '%WEB_LOG%' -Pattern 'localhost:\d+' -Quiet) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    <nul set /p "=."
    goto WEB_LOOP
)

:: ── Extract the web URL ───────────────────────────────────────────────────────
for /f "usebackq delims=" %%U in (`powershell -NoProfile -Command ^
  "(Select-String -Path '%WEB_LOG%' -Pattern 'http://localhost:\d+').Matches[0].Value"`) do (
    set "WEB_URL=%%U"
)

echo.
echo ============================================
echo  Web:    %WEB_URL%
echo  Daemon: see OD Daemon window
echo ============================================
echo Opening Brave Browser...

:: ── Open Brave ────────────────────────────────────────────────────────────────
set "BRAVE=C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
if not exist "%BRAVE%" set "BRAVE=C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"
if exist "%BRAVE%" (
    start "" "%BRAVE%" "%WEB_URL%"
) else (
    echo Brave not found. Opening with default browser...
    start "" "%WEB_URL%"
)

echo.
echo Logs:
echo   Daemon: %DAEMON_LOG%
echo   Web:    %WEB_LOG%
echo.
echo Close the OD Daemon and OD Web windows to stop OpenDesign.
pause
