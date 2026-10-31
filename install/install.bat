@echo off
REM JD Highlighter installer: runs install.ps1 with the right execution policy, in
REM PowerShell 7 (pwsh) when it is installed, else in Windows PowerShell 5.1. The
REM script keeps the window open and asks for the folder if it can't find
REM JDownloader. Extra arguments such as -Accent "#4589ff" or -Variant light are
REM passed through.
where pwsh >nul 2>&1
if %errorlevel%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
)
