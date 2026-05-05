@echo off
chcp 65001 >nul
title Codex
for /f "tokens=2 delims==" %%a in ('findstr "model_provider" "%USERPROFILE%\.codex\config.toml"') do set PROVIDER=%%a
for /f "tokens=2 delims==" %%b in ('findstr "^model " "%USERPROFILE%\.codex\config.toml"') do set MODEL=%%b
set PROVIDER=%PROVIDER:"=%
set PROVIDER=%PROVIDER: =%
set MODEL=%MODEL:"=%
set MODEL=%MODEL: =%
if "%PROVIDER%"=="deepseek-proxy" (
    title Codex + %MODEL%
    echo [1/2] Starting DeepSeek proxy...
    start "Codex Proxy" /min python "D:\codex_dev\codex_deepseek_proxy\codex_proxy.py"
    timeout /t 3 /nobreak >nul
    echo [2/2] Starting Codex CLI...
) else (
    title Codex + %MODEL%
    for /f "tokens=2 delims==" %%c in ('findstr "MODELSCOPE_API_KEY" "D:\codex_dev\.env"') do set MODELSCOPE_API_KEY=%%c
    echo Starting Codex CLI...
)
codex --model %MODEL%
