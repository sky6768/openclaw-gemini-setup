# Telegram 双 Bot 快速开始指南

## 🚀 5 分钟快速配置

这是一个超简化版的快速开始指南，完整文档请查看 [telegram-dual-bot-setup.md](telegram-dual-bot-setup.md)

---

## 📋 前置要求

✅ OpenClaw 已安装并运行  
✅ Gemini API Key 已配置  
✅ Telegram 账号

---

## ⚡ 快速配置步骤

### 1️⃣ 创建 Telegram Bots（5 分钟）

在 Telegram 中与 [@BotFather](https://t.me/BotFather) 对话：

```
你：/newbot
BotFather：请输入 Bot 名称
你：My Pro Assistant
BotFather：请输入用户名
你：your_pro_bot
BotFather：Token: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz

（记录 Token 1）

你：/newbot
BotFather：请输入 Bot 名称
你：My Fast Assistant
BotFather：请输入用户名
你：your_fast_bot
BotFather：Token: 987654321:XYZabcDEFghiJKLmnoPQRstuv

（记录 Token 2）
```

---

### 2️⃣ 创建 OpenClaw Agents（1 分钟）

```bash
# 创建 Pro Agent（使用 Gemini 2.5 Pro）
openclaw agents add pro \
  --workspace ~/.openclaw/workspace-pro \
  --agent-dir ~/.openclaw/agents/pro/agent \
  --model google/gemini-2.5-pro \
  --non-interactive

# 创建 Fast Agent（使用 Gemini 2.0 Flash）
openclaw agents add fast \
  --workspace ~/.openclaw/workspace-fast \
  --agent-dir ~/.openclaw/agents/fast/agent \
  --model google/gemini-2.0-flash \
  --non-interactive
```

---

### 3️⃣ 配置 Telegram（2 分钟）

编辑 `~/.openclaw/openclaw.json`，添加以下内容：

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "accounts": {
        "pro-bot": {
          "name": "Pro Bot",
          "dmPolicy": "open",
          "allowFrom": ["*"],
          "botToken": "粘贴你的 Pro Bot Token"
        },
        "fast-bot": {
          "name": "Fast Bot",
          "dmPolicy": "open",
          "allowFrom": ["*"],
          "botToken": "粘贴你的 Fast Bot Token"
        }
      }
    }
  },
  "bindings": [
    {
      "agentId": "pro",
      "match": {
        "channel": "telegram",
        "accountId": "pro-bot"
      }
    },
    {
      "agentId": "fast",
      "match": {
        "channel": "telegram",
        "accountId": "fast-bot"
      }
    }
  ],
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      }
    }
  }
}
```

---

### 4️⃣ 重启并测试（1 分钟）

```bash
# 重启 Gateway
openclaw gateway restart

# 验证配置
openclaw channels list
openclaw agents list --bindings
```

---

## 🎉 完成！立即使用

### 在 Telegram 中：

1. 搜索 `@your_pro_bot` → 发送 "你好" → 使用 Gemini 2.5 Pro（慢但详细）
2. 搜索 `@your_fast_bot` → 发送 "你好" → 使用 Gemini 2.0 Flash（快速简洁）

---

## 🔧 常见问题

### Q: Bot 没有响应？

```bash
# 检查状态
openclaw channels list

# 查看日志
openclaw logs --max-bytes 200000 | grep telegram | tail -20

# 重启
openclaw gateway restart
```

### Q: 找不到配对请求？

**A**: 你已经使用了开放模式（`dmPolicy: "open"`），无需配对，直接使用！

### Q: 想改回需要配对的模式？

**A**: 将配置中的所有 `"dmPolicy": "open"` 改为 `"dmPolicy": "pairing"`，并移除 `"allowFrom": ["*"]`

---

## 📚 完整文档

详细信息请查看：[Telegram 双 Bot 完整配置指南](telegram-dual-bot-setup.md)

包含：
- ✅ 详细的架构设计
- ✅ 完整的故障排查指南
- ✅ 成本优化建议
- ✅ 安全配置建议
- ✅ 高级配置选项

---

## 🎯 使用建议

### 何时使用 Fast Bot？
- 简单代码生成
- 快速问答
- 日常对话

### 何时使用 Pro Bot？
- 复杂算法设计
- 系统架构讨论
- 深度代码审查

---

**祝你使用愉快！** 🚀
