@echo off
title Codex Provider Switcher

set CFG=%USERPROFILE%\.codex\config.toml
set ENV=D:\codex_dev\.env
set DEE_ENV=D:\codex_dev\codex_deepseek_proxy\.env

:: Read current (strip quotes/spaces for display)
set CUR_PROVIDER=unknown
set CUR_MODEL=unknown
for /f "tokens=2 delims==" %%a in ('findstr "model_provider" "%CFG%" 2^>nul') do set CUR_PROVIDER=%%a
for /f "tokens=2 delims==" %%b in ('findstr "^model " "%CFG%" 2^>nul') do set CUR_MODEL=%%b
set CUR_PROVIDER=%CUR_PROVIDER:"=%
set CUR_PROVIDER=%CUR_PROVIDER: =%
set CUR_MODEL=%CUR_MODEL:"=%
set CUR_MODEL=%CUR_MODEL: =%

:: Save current DEEPSEEK_MODEL before switching
set OLD_DEE=deepseek-v4-flash
for /f "tokens=2 delims==" %%d in ('findstr "DEEPSEEK_MODEL" "%DEE_ENV%" 2^>nul') do set OLD_DEE=%%d
set OLD_DEE=%OLD_DEE:"=%
set OLD_DEE=%OLD_DEE: =%

echo =============================================
echo       Codex Provider Switcher
echo =============================================
echo.
echo  Current: %CUR_PROVIDER% / %CUR_MODEL%
echo.
echo Select:
echo   [1] deepseek-v4-flash        (via proxy)
echo   [2] deepseek-v4-pro          (via proxy)
echo   [3] ZhipuAI/GLM-5.1          (ModelScope)
echo   [4] ZhipuAI/GLM-4.7-Flash    (ModelScope)
echo   [5] MiniMax/MiniMax-M2.7     (ModelScope)
echo   [6] moonshotai/Kimi-K2.5     (ModelScope)
echo   [7] Qwen/Qwen3.5-35B-A3B     (ModelScope)
echo.
set /p choice="Enter 1-7: "

if "%choice%"=="1" (set PROVIDER=deepseek-proxy& set MODEL=deepseek-v4-flash& set NEED_PROXY=1)
if "%choice%"=="2" (set PROVIDER=deepseek-proxy& set MODEL=deepseek-v4-pro& set NEED_PROXY=1)
if "%choice%"=="3" (set PROVIDER=modelscope& set MODEL=ZhipuAI/GLM-5.1& set NEED_PROXY=0)
if "%choice%"=="4" (set PROVIDER=modelscope& set MODEL=ZhipuAI/GLM-4.7-Flash& set NEED_PROXY=0)
if "%choice%"=="5" (set PROVIDER=modelscope& set MODEL=MiniMax/MiniMax-M2.7& set NEED_PROXY=0)
if "%choice%"=="6" (set PROVIDER=modelscope& set MODEL=moonshotai/Kimi-K2.5& set NEED_PROXY=0)
if "%choice%"=="7" (set PROVIDER=modelscope& set MODEL=Qwen/Qwen3.5-35B-A3B& set NEED_PROXY=0)
if "%PROVIDER%"=="" echo Invalid & goto end

:: Kill proxy and Codex processes
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5000" ^| findstr LISTENING') do taskkill /f /pid %%a >nul 2>&1
taskkill /f /im Codex.exe >nul 2>&1

:: Clear Desktop session cache so old threads don't revive
del /f /q "%LOCALAPPDATA%\Packages\OpenAI.Codex_2p2nqsd0c76g0\LocalCache\Roaming\Codex\DIPS*" 2>nul

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
        echo experimental_bearer_token = "ms-ebeacfcc-ca14-4d45-9aed-d70761aa60f0"
    )
    >"%ENV%" (
        echo DEEPSEEK_API_KEY=sk-c9b1581bb73e4915b0b721c98d5dfc01
        echo DEEPSEEK_MODEL=%OLD_DEE%
        echo MODELSCOPE_API_KEY=ms-ebeacfcc-ca14-4d45-9aed-d70761aa60f0
    )
    >"%DEE_ENV%" (
        echo DEEPSEEK_API_KEY=sk-c9b1581bb73e4915b0b721c98d5dfc01
        echo DEEPSEEK_MODEL=%OLD_DEE%
    )
    set MODELSCOPE_API_KEY=ms-ebeacfcc-ca14-4d45-9aed-d70761aa60f0
)
cls
echo =============================================
echo       Switched to: %PROVIDER% / %MODEL%
echo =============================================
echo.
if "%NEED_PROXY%"=="1" (
    echo  Start: launch-Codex-CLI.bat or launch-Codex-Desktop.bat
    echo  (proxy will start automatically)
) else (
    echo  No proxy needed.
    echo  Start: launch-Codex-Desktop.bat or just run: codex
)
echo.
echo  IMPORTANT: Create a NEW THREAD in Codex
echo  after switching. Old threads keep the previous
echo  provider config and will fail to connect.
echo.
:end
pause
