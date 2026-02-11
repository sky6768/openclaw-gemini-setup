# OpenClaw Telegram 双 Bot 配置指南

## 📋 目录

- [概述](#概述)
- [架构设计](#架构设计)
- [前置要求](#前置要求)
- [配置步骤](#配置步骤)
- [使用指南](#使用指南)
- [测试验证](#测试验证)
- [故障排查](#故障排查)
- [成本优化](#成本优化)
- [安全建议](#安全建议)

---

## 概述

本指南将帮助你配置 OpenClaw 的双 Telegram Bot 系统，实现：
- **Bot 1**：使用 Gemini 2.0 Flash 模型（快速、低成本、日常任务）
- **Bot 2**：使用 Gemini 2.5 Pro 模型（强大、复杂任务）

用户可以根据任务复杂度选择与不同的 Bot 对话，自动使用不同的 AI 模型。

### 核心优势

✅ **用户体验最佳**：选择不同 Bot = 自动切换模型  
✅ **配置一次，永久使用**：无需每次手动切换  
✅ **完全隔离**：不同 Bot 的会话互不影响  
✅ **成本可控**：用户自己选择使用快速或高级模型  
✅ **易于扩展**：未来可以添加第三个 Bot

---

## 架构设计

### 系统架构图

```
Telegram 用户
    ↓
    ├─→ @YourProBot (Pro Bot)
    │       ↓
    │   OpenClaw Gateway (路由层)
    │       ↓
    │   Agent "pro"
    │       ↓
    │   🚀 Gemini 2.5 Pro 模型
    │       ↓
    │   📝 详细、深入的响应（5-10秒）
    │
    └─→ @YourFastBot (Fast Bot)
            ↓
        OpenClaw Gateway (路由层)
            ↓
        Agent "fast"
            ↓
        ⚡ Gemini 2.0 Flash 模型
            ↓
        💬 简洁、快速的响应（1-2秒）
```

### Agent 配置表

| Agent ID | 名称 | 模型 | 工作空间 | 用途 |
|---------|------|------|---------|------|
| `pro` | Pro Bot | `google/gemini-2.5-pro` | `~/.openclaw/workspace-pro` | 复杂任务、深度分析 |
| `fast` | Fast Bot | `google/gemini-2.0-flash` | `~/.openclaw/workspace-fast` | 日常任务、快速响应 |

### 路由机制

```json
{
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
  ]
}
```

---

## 前置要求

### 必需条件

- ✅ OpenClaw 已安装并运行（版本 2026.2.9+）
- ✅ Gemini API Key 已配置
- ✅ Telegram 账号
- ✅ 能够访问 @BotFather

### 可选条件

- 📱 多个设备测试（验证隔离性）
- 🔍 日志监控工具

---

## 配置步骤

### 阶段 1：创建 Telegram Bots

#### 步骤 1.1：创建 Pro Bot

1. 打开 Telegram，搜索 `@BotFather`
2. 发送 `/newbot`
3. 输入 Bot 名称：`My Pro Assistant`（或你喜欢的名字）
4. 输入 Bot 用户名：`your_pro_bot`（必须以 `_bot` 结尾）
5. 记录 Bot Token（类似 `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`）

#### 步骤 1.2：创建 Fast Bot

1. 继续与 @BotFather 对话
2. 发送 `/newbot`
3. 输入 Bot 名称：`My Fast Assistant`
4. 输入 Bot 用户名：`your_fast_bot`（必须以 `_bot` 结尾）
5. 记录 Bot Token

#### 步骤 1.3：配置 Bot 设置（可选）

```
/setdescription - 设置 Bot 描述
/setabouttext - 设置"关于"文本
/setuserpic - 上传 Bot 头像
```

**建议描述**：
- **Pro Bot**: "专业 AI 助手 - 使用 Gemini 2.5 Pro，适合复杂任务和深度分析"
- **Fast Bot**: "快速 AI 助手 - 使用 Gemini 2.0 Flash，适合日常任务"

---

### 阶段 2：配置 OpenClaw Agents

#### 步骤 2.1：创建 Pro Agent

```bash
openclaw agents add pro \
  --workspace ~/.openclaw/workspace-pro \
  --agent-dir ~/.openclaw/agents/pro/agent \
  --model google/gemini-2.5-pro \
  --non-interactive
```

**预期输出**：
```
Updated ~/.openclaw/openclaw.json
Workspace OK: ~/.openclaw/workspace-pro
Sessions OK: ~/.openclaw/agents/pro/sessions
Agent: pro
```

#### 步骤 2.2：创建 Fast Agent

```bash
openclaw agents add fast \
  --workspace ~/.openclaw/workspace-fast \
  --agent-dir ~/.openclaw/agents/fast/agent \
  --model google/gemini-2.0-flash \
  --non-interactive
```

#### 步骤 2.3：验证 Agents

```bash
openclaw agents list
```

**预期输出**：
```
Agents:
- main (default)
- pro (Workspace: ~/.openclaw/workspace-pro, Model: google/gemini-2.5-pro)
- fast (Workspace: ~/.openclaw/workspace-fast, Model: google/gemini-2.0-flash)
```

---

### 阶段 3：配置 Telegram 连接

#### 步骤 3.1：编辑配置文件

编辑 `~/.openclaw/openclaw.json`，添加以下配置：

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "groupPolicy": "allowlist",
      "streamMode": "partial",
      "accounts": {
        "pro-bot": {
          "name": "Pro Bot (Gemini 2.5 Pro)",
          "dmPolicy": "open",
          "allowFrom": ["*"],
          "botToken": "YOUR_PRO_BOT_TOKEN_HERE",
          "groupPolicy": "allowlist",
          "streamMode": "partial"
        },
        "fast-bot": {
          "name": "Fast Bot (Gemini 2.0 Flash)",
          "dmPolicy": "open",
          "allowFrom": ["*"],
          "botToken": "YOUR_FAST_BOT_TOKEN_HERE",
          "groupPolicy": "allowlist",
          "streamMode": "partial"
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

**重要**：
- 将 `YOUR_PRO_BOT_TOKEN_HERE` 替换为实际的 Pro Bot Token
- 将 `YOUR_FAST_BOT_TOKEN_HERE` 替换为实际的 Fast Bot Token

#### 步骤 3.2：验证配置

```bash
# 验证 JSON 语法
cat ~/.openclaw/openclaw.json | jq '.channels.telegram'

# 验证 Agents 绑定
openclaw agents list --bindings
```

**预期输出**：
```
Agents:
- pro (Pro Bot)
  Routing rules: 1
  Routing rules:
    - telegram accountId=pro-bot
- fast (Fast Bot)
  Routing rules: 1
  Routing rules:
    - telegram accountId=fast-bot
```

---

### 阶段 4：启动和验证

#### 步骤 4.1：启用 Telegram 插件

如果配置文件中 `plugins.entries.telegram.enabled` 为 `false`，需要改为 `true`。

#### 步骤 4.2：重启 Gateway

```bash
openclaw gateway restart
```

#### 步骤 4.3：验证服务状态

```bash
# 检查 Gateway 状态
openclaw status

# 检查 Channels 状态
openclaw channels list
```

**预期输出**：
```
Chat channels:
- Telegram fast-bot (Fast Bot (Gemini 2.0 Flash)): configured, token=config, enabled
- Telegram pro-bot (Pro Bot (Gemini 2.5 Pro)): configured, token=config, enabled
```

#### 步骤 4.4：查看启动日志

```bash
openclaw logs --max-bytes 200000 | grep telegram | tail -20
```

**成功启动的标志**：
```
[fast-bot] starting provider (@your_fast_bot)
[pro-bot] starting provider (@your_pro_bot)
```

---

## 使用指南

### 使用 Pro Bot（复杂任务）

1. **在 Telegram 中搜索你的 Pro Bot**：`@your_pro_bot`
2. **点击 Start**
3. **直接发送消息**（开放模式，无需配对）：
   ```
   你好，请介绍一下你自己
   ```
4. **测试复杂任务**：
   ```
   请实现一个 AVL 树的自平衡算法，包括插入、删除和旋转操作，
   并详细解释每一步的原理和时间复杂度分析
   ```

**特点**：
- ⏱️ 响应时间：5-10 秒
- 📝 回答质量：详细、深入、全面
- 💰 成本：中等

### 使用 Fast Bot（日常任务）

1. **在 Telegram 中搜索你的 Fast Bot**：`@your_fast_bot`
2. **点击 Start**
3. **直接发送消息**：
   ```
   你好，请介绍一下你自己
   ```
4. **测试快速任务**：
   ```
   用 Python 写一个快速排序算法
   ```

**特点**：
- ⚡ 响应时间：1-2 秒
- 💬 回答质量：简洁、直接、实用
- 💰 成本：低

---

## 测试验证

### 测试 1：基本功能测试

**目标**：验证两个 Bot 都能正常响应

**步骤**：
1. 向 Pro Bot 发送：`你好，你使用的是什么模型？`
2. 向 Fast Bot 发送：`你好，你使用的是什么模型？`

**预期结果**：
- 两个 Bot 都能正常响应
- Pro Bot 可能提到 Gemini 2.5 Pro
- Fast Bot 可能提到 Gemini 2.0 Flash

### 测试 2：响应速度对比

**目标**：验证模型性能差异

**步骤**：
1. 向两个 Bot 都发送相同的问题：
   ```
   请解释什么是二叉搜索树，并提供 Python 实现
   ```

**预期结果**：
- Fast Bot 响应明显更快（1-2 秒）
- Pro Bot 响应较慢（5-10 秒）
- Pro Bot 的回答更详细、更深入

### 测试 3：会话隔离验证

**目标**：验证不同 Bot 的会话完全独立

**步骤**：
1. 向 Pro Bot 发送：`我喜欢 Python 编程`
2. Pro Bot 确认后，向 Fast Bot 发送：`我刚才说我喜欢什么？`

**预期结果**：
- Fast Bot 回答"我不知道"或类似内容
- 确认两个 Bot 的会话历史完全隔离

### 测试 4：路由验证

**目标**：确认消息路由到正确的 Agent

**步骤**：
```bash
# 实时查看日志
openclaw logs --follow

# 同时与两个 Bot 对话
# 观察日志中的 agent ID 标识
```

**预期日志**：
```
[telegram:pro-bot] → agent:pro → model:gemini-2.5-pro
[telegram:fast-bot] → agent:fast → model:gemini-2.0-flash
```

### 测试 5：复杂任务对比

**Pro Bot 测试**：
```
请设计一个分布式系统的缓存架构，包括：
1. 缓存策略（LRU、LFU 等）
2. 一致性保证
3. 故障恢复机制
4. 性能优化方案
```

**Fast Bot 测试**：
```
写一个简单的缓存类
```

**预期结果**：
- Pro Bot 提供详细的系统设计文档
- Fast Bot 提供简洁的代码实现

---

## 故障排查

### 问题 1：Bot 没有响应

**症状**：向 Bot 发送消息后没有任何回复

**排查步骤**：

1. **检查 Gateway 状态**：
   ```bash
   openclaw status
   ```
   确认 Gateway 服务正在运行

2. **检查 Channels 状态**：
   ```bash
   openclaw channels list
   ```
   确认两个 Bot 都显示为 `enabled`

3. **查看日志**：
   ```bash
   openclaw logs --max-bytes 200000 | grep -i telegram | tail -30
   ```
   查找错误信息

4. **验证配置**：
   ```bash
   openclaw agents list --bindings
   cat ~/.openclaw/openclaw.json | jq '.channels.telegram'
   ```

5. **重启 Gateway**：
   ```bash
   openclaw gateway restart
   ```

### 问题 2：配对请求无法找到

**症状**：配置为 pairing 模式，但找不到配对请求

**解决方案**：改为开放模式

编辑 `~/.openclaw/openclaw.json`：
```json
{
  "channels": {
    "telegram": {
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "accounts": {
        "pro-bot": {
          "dmPolicy": "open",
          "allowFrom": ["*"]
        },
        "fast-bot": {
          "dmPolicy": "open",
          "allowFrom": ["*"]
        }
      }
    }
  }
}
```

然后重启：
```bash
openclaw gateway restart
```

### 问题 3：Bot Token 无效

**症状**：日志中显示认证错误

**排查步骤**：

1. **验证 Token 格式**：
   - Token 应该类似：`123456789:ABCdefGHIjklMNOpqrsTUVwxyz`
   - 包含数字、冒号和字母

2. **在 BotFather 中确认**：
   - 发送 `/mybots` 到 @BotFather
   - 选择你的 Bot
   - 查看 API Token

3. **重新配置 Token**：
   ```bash
   # 编辑配置文件
   nano ~/.openclaw/openclaw.json
   
   # 重启
   openclaw gateway restart
   ```

### 问题 4：Telegram 插件未启用

**症状**：`openclaw channels list` 显示为空

**排查步骤**：

1. **检查插件状态**：
   ```bash
   cat ~/.openclaw/openclaw.json | jq '.plugins.entries.telegram'
   ```

2. **启用插件**：
   编辑配置文件，确保：
   ```json
   {
     "plugins": {
       "entries": {
         "telegram": {
           "enabled": true
         }
       }
     }
   }
   ```

3. **重启 Gateway**

### 问题 5：路由不工作

**症状**：消息发送到错误的 Agent

**排查步骤**：

1. **验证 Bindings**：
   ```bash
   openclaw agents list --bindings
   ```

2. **检查配置**：
   ```bash
   cat ~/.openclaw/openclaw.json | jq '.bindings'
   ```

3. **确认 accountId 匹配**：
   - Bindings 中的 `accountId` 必须与 channels 配置中的账号名称匹配
   - 例如：`accountId: "pro-bot"` 对应 `channels.telegram.accounts["pro-bot"]`

---

## 成本优化

### 成本估算

#### Gemini API 定价（2026 年参考）

| 模型 | 输入成本/M tokens | 输出成本/M tokens | 免费额度 |
|------|------------------|------------------|---------|
| Gemini 2.0 Flash | 极低 | 极低 | 每天大量免费请求 |
| Gemini 2.5 Pro | 中等 | 中等 | 每天有限免费请求 |

#### 使用场景分析

**轻度使用**（每天 20-50 次对话）：
- Fast Bot (80%): $0/月（免费额度内）
- Pro Bot (20%): $0-2/月
- **总计**: $0-2/月

**中度使用**（每天 100-200 次对话）：
- Fast Bot (70%): $1-3/月
- Pro Bot (30%): $3-8/月
- **总计**: $4-11/月

**重度使用**（每天 500+ 次对话）：
- Fast Bot (60%): $5-10/月
- Pro Bot (40%): $10-30/月
- **总计**: $15-40/月

### 优化建议

#### 策略 1：优先使用 Fast Bot

**原则**：默认使用 Fast Bot，仅在必要时使用 Pro Bot

**适合 Fast Bot 的场景**：
- ✅ 简单代码生成
- ✅ 快速问答
- ✅ 代码格式化
- ✅ 文档查询
- ✅ 日常对话

**需要切换到 Pro Bot 的场景**：
- 🎯 复杂算法设计
- 🎯 系统架构设计
- 🎯 深度代码审查
- 🎯 多步骤复杂任务
- 🎯 需要详细解释的技术问题

#### 策略 2：监控使用量

**设置预算提醒**：

1. 访问 Google Cloud Console
2. 导航到 Billing → Budgets & alerts
3. 创建预算：
   - 名称：`Gemini API Budget`
   - 金额：例如 $20/月
   - 阈值：50%, 90%, 100%
4. 配置通知邮箱

**监控命令**：
```bash
# 查看当前状态
openclaw status

# 查看会话统计
openclaw agents list --bindings
```

#### 策略 3：使用白名单模式（生产环境）

**限制访问人员**，避免被滥用：

```json
{
  "channels": {
    "telegram": {
      "dmPolicy": "allowlist",
      "allowFrom": [
        "your_telegram_username",
        "team_member_1",
        "team_member_2"
      ]
    }
  }
}
```

---

## 安全建议

### 建议 1：使用白名单模式

**开发/测试环境**可以使用开放模式：
```json
{
  "dmPolicy": "open",
  "allowFrom": ["*"]
}
```

**生产环境**应该使用白名单：
```json
{
  "dmPolicy": "allowlist",
  "allowFrom": [
    "authorized_user_1",
    "authorized_user_2"
  ]
}
```

### 建议 2：使用配对模式

**最安全的方式**是使用配对模式：
```json
{
  "dmPolicy": "pairing"
}
```

**配对流程**：
1. 用户首次向 Bot 发送消息
2. 系统生成配对码
3. 管理员批准配对
4. 用户可以继续使用

### 建议 3：保护敏感信息

**不要在公开仓库中提交**：
- ❌ Bot Token
- ❌ API Keys
- ❌ Gateway Token

**使用环境变量**：
```bash
# 在 ~/.openclaw/.env 中配置
TELEGRAM_PRO_BOT_TOKEN=your_token_here
TELEGRAM_FAST_BOT_TOKEN=your_token_here
```

**在配置文件中引用**：
```json
{
  "botToken": "${TELEGRAM_PRO_BOT_TOKEN}"
}
```

### 建议 4：定期审计

**定期检查**：
```bash
# 查看活跃会话
openclaw status

# 查看日志
openclaw logs --max-bytes 200000 | grep telegram

# 安全审计
openclaw security audit
```

### 建议 5：限制群组访问

**配置**：
```json
{
  "groupPolicy": "allowlist",
  "groups": {
    "allowed_group_id_1": {},
    "allowed_group_id_2": {}
  }
}
```

---

## 高级配置

### 自定义 Agent 人格

**Pro Agent 人格**（`~/.openclaw/workspace-pro/SOUL.md`）：
```markdown
# Pro Bot 人格设定

你是一个专业的 AI 技术顾问，擅长深度分析和复杂问题解决。

## 核心特点
- 详细、严谨、全面
- 提供多角度分析
- 注重理论和实践结合
- 给出可落地的建议

## 擅长领域
- 系统架构设计
- 复杂算法分析
- 代码审查和优化
- 技术选型建议

## 沟通风格
- 使用专业术语，但确保清晰
- 提供充分的背景说明
- 给出多种解决方案
- 分析每种方案的优劣
```

**Fast Agent 人格**（`~/.openclaw/workspace-fast/SOUL.md`）：
```markdown
# Fast Bot 人格设定

你是一个快速响应的 AI 助手，专注于提供简洁、直接的答案。

## 核心特点
- 简洁、高效、直接
- 快速给出可用方案
- 代码优先，解释其次

## 擅长领域
- 快速代码生成
- 常见问题解答
- 代码调试
- 简单重构

## 沟通风格
- 直奔主题
- 提供可直接使用的代码
- 简短的注释
- 必要时才详细解释
```

### 配置模型别名

**简化模型切换**（在会话中使用 `/model` 命令时）：

```bash
# 添加别名
openclaw models aliases add pro google/gemini-2.5-pro
openclaw models aliases add fast google/gemini-2.0-flash

# 重启生效
openclaw gateway restart
```

**使用别名**：
```
/model pro   ← 切换到 Pro 模型
/model fast  ← 切换到 Fast 模型
```

### 配置 Fallback 模型

**为每个 Agent 配置备用模型**：

编辑 `~/.openclaw/openclaw.json`：
```json
{
  "agents": {
    "list": [
      {
        "id": "pro",
        "model": {
          "primary": "google/gemini-2.5-pro",
          "fallbacks": ["google/gemini-2.0-flash"]
        }
      },
      {
        "id": "fast",
        "model": {
          "primary": "google/gemini-2.0-flash",
          "fallbacks": ["google/gemini-2.5-pro"]
        }
      }
    ]
  }
}
```

---

## 常见问题 FAQ

### Q1: 可以添加第三个 Bot 吗？

**A**: 可以！按照相同的步骤：
1. 在 BotFather 创建新 Bot
2. 创建新 Agent：`openclaw agents add another-bot ...`
3. 添加 Telegram 账号配置
4. 添加 Binding 规则

### Q2: 如何切换回单模型配置？

**A**: 删除不需要的 Agent 和配置：
```bash
# 删除 Agent
openclaw agents delete pro
openclaw agents delete fast

# 移除 Telegram 配置
# 编辑 ~/.openclaw/openclaw.json，删除 channels.telegram 和 bindings
```

### Q3: Bot 可以在群组中使用吗？

**A**: 可以，需要配置群组策略：
```json
{
  "groupPolicy": "allowlist",
  "groups": {
    "*": {
      "requireMention": true
    }
  }
}
```

然后将 Bot 添加到群组，@提及 Bot 即可。

### Q4: 如何备份配置？

**A**: 备份以下文件：
```bash
# 备份配置
cp ~/.openclaw/openclaw.json ~/openclaw-backup.json

# 备份工作空间
tar -czf ~/openclaw-workspaces-backup.tar.gz \
  ~/.openclaw/workspace-pro \
  ~/.openclaw/workspace-fast

# 备份会话
tar -czf ~/openclaw-sessions-backup.tar.gz \
  ~/.openclaw/agents/pro/sessions \
  ~/.openclaw/agents/fast/sessions
```

### Q5: 如何迁移到新服务器？

**A**: 
1. 备份配置（参考 Q4）
2. 在新服务器安装 OpenClaw
3. 恢复配置文件
4. 重启 Gateway

```bash
# 在新服务器
cp openclaw-backup.json ~/.openclaw/openclaw.json
tar -xzf openclaw-workspaces-backup.tar.gz -C ~/.openclaw/
openclaw gateway restart
```

---

## 文件结构

```
~/.openclaw/
├── openclaw.json                    # 主配置文件
├── .env                             # 环境变量（API Keys）
├── workspace/                       # Main Agent 工作空间
├── workspace-pro/                   # Pro Agent 工作空间
│   ├── SOUL.md                      # Pro Bot 人格设定
│   ├── AGENTS.md
│   └── USER.md
├── workspace-fast/                  # Fast Agent 工作空间
│   ├── SOUL.md                      # Fast Bot 人格设定
│   ├── AGENTS.md
│   └── USER.md
├── agents/
│   ├── main/
│   │   ├── agent/
│   │   └── sessions/
│   ├── pro/
│   │   ├── agent/                   # Pro Agent 状态
│   │   └── sessions/                # Pro Bot 会话历史
│   └── fast/
│       ├── agent/                   # Fast Agent 状态
│       └── sessions/                # Fast Bot 会话历史
└── credentials/                     # OAuth 凭证目录
```

---

## 参考资源

### 官方文档

- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [OpenClaw Multi-Agent 配置](https://docs.openclaw.ai/concepts/multi-agent)
- [OpenClaw Telegram 集成](https://docs.openclaw.ai/channels/telegram)
- [OpenClaw 模型配置](https://docs.openclaw.ai/cli/models)

### 社区资源

- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw Discord](https://discord.gg/openclaw)
- [OpenClaw Reddit](https://reddit.com/r/openclaw)

### Telegram Bot API

- [BotFather 官方文档](https://core.telegram.org/bots#botfather)
- [Telegram Bot API 文档](https://core.telegram.org/bots/api)

### Gemini API

- [Gemini API 文档](https://ai.google.dev/docs)
- [Gemini API Key 申请](https://makersuite.google.com/app/apikey)
- [Gemini 定价](https://ai.google.dev/pricing)

---

## 更新日志

### v1.0.0 (2026-02-11)

- ✅ 初始版本
- ✅ 双 Bot 配置完整指南
- ✅ 包含故障排查和成本优化
- ✅ 添加安全建议和 FAQ

---

## 许可证

本文档遵循 MIT 许可证。

---

## 贡献

欢迎提交 Issue 和 Pull Request！

如果你发现任何问题或有改进建议，请：
1. Fork 本仓库
2. 创建你的分支 (`git checkout -b feature/improvement`)
3. 提交你的修改 (`git commit -am 'Add some improvement'`)
4. 推送到分支 (`git push origin feature/improvement`)
5. 创建 Pull Request

---

## 联系方式

如有问题或需要帮助，请：
- 提交 GitHub Issue
- 加入 OpenClaw Discord 社区
- 查看官方文档

---

**祝你配置顺利！享受你的双模型 AI 助手！** 🚀
