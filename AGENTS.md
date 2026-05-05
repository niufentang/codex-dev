# Codex Dev Environment Guide

## Architecture

This repo configures OpenAI's Codex CLI/Desktop to use third-party model providers.

- **DeepSeek V4** — via a local Python proxy (`codex_deepseek_proxy/codex_proxy.py`) that translates OpenAI Responses API → DeepSeek Chat Completions API. Codex CLI only speaks Responses API (`wire_api = "responses"`); DeepSeek only supports Chat Completions, so the proxy is mandatory.
- **ModelScope (ZhipuAI)** — direct connection, no proxy needed. ModelScope natively supports the Responses API.

## Key Files

| File | Purpose |
|---|---|
| `切换模型.bat` | Interactive provider/model switcher. Writes `~/.codex/config.toml` and both `.env` files. Kills proxy on port 5000 when switching away from DeepSeek. |
| `launch-Codex-CLI.bat` | Starts proxy + Codex CLI TUI. Reads model from `codex_deepseek_proxy/.env`. |
| `launch-Codex-Desktop.bat` | Starts proxy + Codex Desktop app. |
| `关闭代理.bat` | Kills the proxy process on port 5000. |
| `codex_deepseek_proxy/codex_proxy.py` | Flask proxy on port 5000. Reads `DEEPSEEK_API_KEY` and `DEEPSEEK_MODEL` from its own `.env`. |
| `D:\codex_dev\.env` | Shared config — all API keys for both providers. |
| `codex_deepseek_proxy\.env` | DeepSeek-only keys (proxy reads this directly). |

## Switching Providers

Run `切换模型.bat` to choose between:
1. `deepseek-v4-flash` (proxy)
2. `deepseek-v4-pro` (proxy)
3. `ZhipuAI/GLM-5.1` (ModelScope, direct)
4. `ZhipuAI/GLM-4.7-Flash` (ModelScope, direct)

ModelScope mode requires `MODELSCOPE_API_KEY` env var (ms-...); DeepSeek mode requires `DEEPSEEK_API_KEY` env var (sk-...). Both are persisted in `.env` files and set by the switcher.

## Environment Variables

- `DEEPSEEK_API_KEY` — DeepSeek API key
- `DEEPSEEK_MODEL` — Active DeepSeek model name
- `MODELSCOPE_API_KEY` — ModelScope API key (for ZhipuAI models)
- `DEEPSEEK_URL` — Override upstream URL (default: `https://api.deepseek.com/v1/chat/completions`)
- `DEEPSEEK_DEBUG=1` — Enable proxy debug logging to `proxy_debug.log`

## Gotchas

- `codex` CLI (v0.121.0) is installed via winget at `WinGet\Links\codex.exe`.
- Codex Desktop app (`Codex.exe`) is a separate install at `WindowsApps\OpenAI.Codex_...\app\`.
- The proxy must be running before Codex starts (launch scripts handle this with a 3s delay).
- Switching models requires killing the old proxy (the switcher does this automatically).
- Batch files must use ANSI encoding (GBK on Chinese Windows). UTF-8 without BOM causes cmd parsing errors.
- `py` launcher may not be available; use `python` explicitly in scripts.

### 常用命令
```bash
# 仓库
gh repo clone <repo>
gh repo create
# 代码拉取、提交、推送
git pull      # 拉取最新代码
git add .     # 添加变更
git commit -m "提交信息"  # 提交代码
git push      # 推送到远程
# Issue
gh issue list
gh issue create
# PR
gh pr list
gh pr create
gh pr checkout <num>
gh pr merge
# 帮助
gh help
```