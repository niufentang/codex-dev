@echo off
chcp 65001 >nul
title Codex + DeepSeek
for /f "tokens=2 delims==" %%a in ('findstr "DEEPSEEK_MODEL" "D:\codex_dev\codex_deepseek_proxy\.env"') do set MODEL=%%a
if "%MODEL%"=="" set MODEL=deepseek-v4-flash
echo [1/2] Starting DeepSeek proxy...
start "Codex Proxy" /min python "D:\codex_dev\codex_deepseek_proxy\codex_proxy.py"
timeout /t 3 /nobreak >nul
echo [2/2] Starting Codex CLI...
codex --model %MODEL%
