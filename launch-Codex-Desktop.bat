@echo off
chcp 65001 >nul
title Codex Desktop
:: Read provider and model from config.toml
for /f "tokens=2 delims==" %%a in ('findstr "model_provider" "%USERPROFILE%\.codex\config.toml"') do set PROVIDER=%%a
for /f "tokens=2 delims==" %%b in ('findstr "^model " "%USERPROFILE%\.codex\config.toml"') do set MODEL=%%b
:: Strip quotes and spaces
set PROVIDER=%PROVIDER:"=%
set PROVIDER=%PROVIDER: =%
set MODEL=%MODEL:"=%
set MODEL=%MODEL: =%

:: Start proxy only for DeepSeek
if "%PROVIDER%"=="deepseek-proxy" (
    title Codex Desktop + %MODEL%
    echo [1/2] Starting DeepSeek proxy...
    start "Codex Proxy" /min python "D:\codex_dev\codex_deepseek_proxy\codex_proxy.py"
    timeout /t 3 /nobreak >nul
    echo [2/2] Launching Codex Desktop...
) else (
    title Codex Desktop + %MODEL%
    echo Launching Codex Desktop...
)
start "" "C:\Program Files\WindowsApps\OpenAI.Codex_26.429.3425.0_x64__2p2nqsd0c76g0\app\Codex.exe"
