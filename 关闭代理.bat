@echo off
chcp 65001 >nul
title 关闭 Codex 代理

echo 正在关闭 DeepSeek 代理...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5000" ^| findstr LISTENING') do (
    taskkill /f /pid %%a >nul 2>&1
)
echo 代理已关闭。
timeout /t 2 /nobreak >nul
