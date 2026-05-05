=============================================
   Codex + DeepSeek V4 配置说明
=============================================

一、文件说明
-----------

  切换模型.bat
     切换 DeepSeek 模型 (flash / pro)，杀死旧代理并更新配置。

  launch-Codex-CLI.bat
     启动代理 + Codex CLI 终端界面。

  launch-Codex-Desktop.bat
     启动代理 + Codex 桌面版应用。

  关闭代理.bat
     停止正在运行的 DeepSeek 代理进程 (端口 5000)。

  codex_deepseek_proxy/
     codex_proxy.py     - Responses API -> Chat Completions 翻译代理
     .env               - API Key 和模型配置

二、使用流程
-----------

  1. 双击 切换模型.bat，选择模型
  2. 双击 launch-Codex-CLI.bat 或 launch-Codex-Desktop.bat
  3. 等待代理启动 (约 3 秒)
  4. 正常使用 Codex

三、模型说明
-----------

  deepseek-v4-flash  - 快速，适合日常编码
  deepseek-v4-pro    - 高质量，适合复杂任务

四、切换模型
-----------

  运行 切换模型.bat -> 选 1 或 2 -> 启动脚本自动使用新模型

五、常见问题
-----------

  Q: 启动后报 404
  A: 代理未启动。先运行 launch-*.bat 或手动运行:
     python D:\codex_dev\codex_deepseek_proxy\codex_proxy.py

  Q: 切换模型后没效果
  A: 切换脚本会自动杀死旧代理，确保启动脚本重新启动代理。

  Q: Codex 找不到 codex.exe
  A: 确保 Codex 已安装: winget install OpenAI.Codex

  Q: 端口 5000 被占用
  A: 运行 关闭代理.bat 或手动:
     netstat -ano | findstr :5000
     taskkill /f /pid <PID>
