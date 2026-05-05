@echo off
title Codex Provider Switcher

set CFG=%USERPROFILE%\.codex\config.toml
set ENV=D:\codex_dev\.env
set DEE_ENV=D:\codex_dev\codex_deepseek_proxy\.env

:: Read current
set CUR_PROVIDER=unknown
set CUR_MODEL=unknown
for /f "tokens=2 delims==" %%a in ('findstr "model_provider" "%CFG%" 2^>nul') do set CUR_PROVIDER=%%a
for /f "tokens=2 delims==" %%b in ('findstr "^model " "%CFG%" 2^>nul') do set CUR_MODEL=%%b

echo =============================================
echo       Codex Provider Switcher
echo =============================================
echo.
echo  Current: %CUR_PROVIDER% / %CUR_MODEL%
echo.
echo Select:
echo   [1] deepseek-v4-flash  (via proxy)
echo   [2] deepseek-v4-pro    (via proxy)
echo   [3] ZhipuAI/GLM-5.1    (ModelScope direct)
echo   [4] ZhipuAI/GLM-4.7-Flash (ModelScope direct)
echo.
set /p choice="Enter 1-4: "

if "%choice%"=="1" set PROVIDER=deepseek-proxy& set MODEL=deepseek-v4-flash& set NEED_PROXY=1
if "%choice%"=="2" set PROVIDER=deepseek-proxy& set MODEL=deepseek-v4-pro& set NEED_PROXY=1
if "%choice%"=="3" set PROVIDER=modelscope& set MODEL=ZhipuAI/GLM-5.1& set NEED_PROXY=0
if "%choice%"=="4" set PROVIDER=modelscope& set MODEL=ZhipuAI/GLM-4.7-Flash& set NEED_PROXY=0
if "%PROVIDER%"=="" echo Invalid & goto end

:: Kill proxy if switching away from DeepSeek
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5000" ^| findstr LISTENING') do taskkill /f /pid %%a >nul 2>&1

:: Write config.toml
if "%PROVIDER%"=="deepseek-proxy" (
    >"%CFG%" (
        echo model_provider = "deepseek-proxy"
        echo model = "%MODEL%"
        echo.
        echo [model_providers.deepseek-proxy]
        echo name = "DeepSeek Proxy"
        echo base_url = "http://127.0.0.1:5000"
        echo wire_api = "responses"
    )
    >"%ENV%" (
        echo DEEPSEEK_API_KEY=sk-c9b1581bb73e4915b0b721c98d5dfc01
        echo DEEPSEEK_MODEL=%MODEL%
        echo MODELSCOPE_API_KEY=ms-ebeacfcc-ca14-4d45-9aed-d70761aa60f0
    )
    >"%DEE_ENV%" (
        echo DEEPSEEK_API_KEY=sk-c9b1581bb73e4915b0b721c98d5dfc01
        echo DEEPSEEK_MODEL=%MODEL%
    )
) else (
    >"%CFG%" (
        echo model_provider = "modelscope"
        echo model = "%MODEL%"
        echo.
        echo [model_providers.modelscope]
        echo name = "Modelscope"
        echo base_url = "https://api-inference.modelscope.cn/v1"
        echo env_key = "MODELSCOPE_API_KEY"
    )
    :: Write ModelScope key to root .env
    >"%ENV%" (
        echo DEEPSEEK_API_KEY=sk-c9b1581bb73e4915b0b721c98d5dfc01
        echo DEEPSEEK_MODEL=%MODEL%
        echo MODELSCOPE_API_KEY=ms-ebeacfcc-ca14-4d45-9aed-d70761aa60f0
    )
    :: Write DeepSeek key to proxy .env
    >"%DEE_ENV%" (
        echo DEEPSEEK_API_KEY=sk-c9b1581bb73e4915b0b721c98d5dfc01
        echo DEEPSEEK_MODEL=%MODEL%
    )
    :: Set env var for current session
    set MODELSCOPE_API_KEY=ms-ebeacfcc-ca14-4d45-9aed-d70761aa60f0
)

cls
echo =============================================
echo       Switched to: %PROVIDER% / %MODEL%
echo =============================================
echo.
if "%NEED_PROXY%"=="1" (
    echo  Start: launch-Codex-CLI.bat or launch-Codex-Desktop.bat
) else (
    echo  No proxy needed. Just run: codex
    echo  Or use: launch-Codex-CLI.bat (proxy will idle harmlessly)
)
echo.
:end
pause
