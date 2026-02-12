# Claude Sonnet 4.5 配置完成指南

**配置时间**: 2026-02-12  
**配置状态**: ✅ 配置完成，⏳ 等待OAuth认证

---

## ✅ 已完成的配置

### 1. 模型配置
- ✅ 已将默认模型设置为 `google-antigravity/claude-sonnet-4-5`
- ✅ 已配置Fallback机制：Claude Sonnet 4.5 → Gemini 2.5 Pro → Gemini 2.0 Flash
- ✅ 已启用Google Antigravity Auth插件

### 2. Agent配置

| Agent ID | 名称 | 模型 | 状态 |
|----------|------|------|------|
| **main** (默认) | Main Agent | Claude Sonnet 4.5 | ⏳ 需要OAuth |
| **pro** | Pro Bot | Gemini 2.5 Pro | ✅ 正常工作 |
| **fast** | Claude Bot | Claude Sonnet 4.5 | ⏳ 需要OAuth |

### 3. Telegram Bot配置

- **Pro Bot** (token: 8130...NLA)
  - 显示名称: "Pro Bot (Gemini 2.5 Pro)"
  - 模型: Gemini 2.5 Pro
  - 状态: ✅ 可用

- **Claude Bot** (token: 8468...vOM)  
  - 显示名称: "Claude Bot (Sonnet 4.5)"
  - 模型: Claude Sonnet 4.5
  - 状态: ⏳ 需要OAuth认证

### 4. 测试结果

✅ **Gemini Pro Bot测试通过**
```bash
$ openclaw agent --agent pro --message "你好！"
回应：正常，Gemini 2.5 Pro工作正常
```

⏳ **Claude Sonnet 4.5需要认证**
```bash
$ openclaw agent --agent main --message "你好！"
状态：自动回退到Gemini Pro（Fallback机制工作正常）
原因：No API key found for provider "google-antigravity"
```

---

## 🔑 下一步：完成OAuth认证

### 为什么需要OAuth认证？

Google Antigravity使用OAuth 2.0认证，而不是简单的API Key。这是因为它通过Google Cloud Code Assist服务来访问Claude模型，需要更高级别的授权。

### 认证方式

有两种方式完成OAuth认证：

#### **方式1：使用自动化脚本（推荐）**

我已经为您创建了一个认证脚本：

```bash
bash ~/.openclaw/authenticate-claude.sh
```

脚本会：
1. 引导您完成OAuth流程
2. 自动打开浏览器进行Google登录
3. 验证认证状态
4. 提供测试命令

#### **方式2：手动认证**

```bash
# 1. 设置PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# 2. 启动OAuth认证
openclaw models auth login --provider google-antigravity

# 3. 按照提示完成浏览器授权
#    - 访问生成的URL（可能自动打开）
#    - 使用您有300 credits的Google账号登录
#    - 授权OpenClaw访问Cloud Code Assist
#    - 浏览器重定向到 http://localhost:51121/callback
#    - 看到"Authentication successful"提示

# 4. 验证认证状态
openclaw models list | grep claude-sonnet
```

### OAuth认证流程详解

1. **命令执行**
   ```
   openclaw models auth login --provider google-antigravity
   ```

2. **生成授权URL**
   - OpenClaw会生成一个Google OAuth URL
   - URL包含所需的权限范围和回调地址

3. **浏览器授权**
   - 浏览器自动打开（或手动访问URL）
   - 选择您的Google账号（有300 credits的账号）
   - 查看权限请求并点击"允许"

4. **回调处理**
   - Google重定向到 `http://localhost:51121/callback?code=...`
   - OpenClaw的本地服务器接收授权码
   - 交换授权码获取访问token

5. **保存认证信息**
   - Token保存到 `~/.openclaw/agents/main/agent/auth-profiles.json`
   - 同时也会保存到其他Agent的auth-profiles.json（如fast）

6. **完成**
   - 终端显示 "Authentication successful"
   - 现在可以使用Claude Sonnet 4.5模型

---

## ✅ 认证完成后的验证步骤

### 1. 检查模型认证状态

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
openclaw models list
```

期望输出：
```
Model                                      Input      Ctx      Local Auth  Tags
google-antigravity/claude-sonnet-4-5       text+image 195k     no    yes   default,configured
google/gemini-2.5-pro                      text+image 1024k    no    yes   fallback#1,configured
google/gemini-2.0-flash                    text+image 1024k    no    yes   fallback#2,configured
```

**注意**: `claude-sonnet-4-5` 的 Auth 列应该显示 **yes** ✅

### 2. 测试Main Agent（Claude Sonnet 4.5）

```bash
openclaw agent --agent main --message "你好！请告诉我你是什么模型，并简要介绍你的能力。请用中文回答。"
```

**期望结果**: 模型自我介绍为Claude，而不是Gemini

### 3. 测试Fast Bot（Claude Sonnet 4.5）

```bash
openclaw agent --agent fast --message "你好！请确认你是Claude模型。"
```

### 4. 测试Fallback机制

如果想测试fallback是否工作，可以暂时禁用Antigravity：
```bash
openclaw plugins disable google-antigravity-auth
openclaw gateway restart
openclaw agent --agent main --message "你好"  # 应该使用Gemini Pro

# 恢复
openclaw plugins enable google-antigravity-auth
openclaw gateway restart
```

### 5. 检查Agent配置

```bash
openclaw agents list
```

期望输出：
```
- main (default)
  Model: google-antigravity/claude-sonnet-4-5
- pro (Pro Bot)
  Model: google/gemini-2.5-pro
- fast (Claude Bot)
  Model: google-antigravity/claude-sonnet-4-5
```

---

## 📊 成本估算（使用您的300 Credits）

### Claude Sonnet 4.5定价
- **输入**: $3 per million tokens
- **输出**: $15 per million tokens
- **缓存读取**: $0.30 per million tokens
- **缓存写入**: $3.75 per million tokens

### 实际使用估算

假设平均每次对话：
- 输入：约1,000 tokens
- 输出：约500 tokens

**单次对话成本**:
```
成本 = (1,000 × $3/1M) + (500 × $15/1M)
     = $0.003 + $0.0075
     = $0.0105 per conversation
```

**300 Credits可进行的对话次数**:
```
次数 = $300 ÷ $0.0105
     ≈ 28,571 次对话
```

### 与Opus 4.5对比

如果使用Opus 4.5 ($5/$25):
- 单次对话成本: $0.0175
- 300 Credits可用: 17,143次
- **使用Sonnet 4.5节省40%！**

### 省钱建议

1. **轻量任务用Gemini**: 简单问答用Pro Bot (免费)
2. **复杂任务用Claude**: 需要深度理解时用Main/Fast Bot
3. **监控使用**: 在Google Cloud Console查看Credits使用情况
4. **设置提醒**: 在剩余Credits低于某个阈值时通知

---

## 🔧 常见问题排除

### 问题1: OAuth认证失败

**症状**: 浏览器打不开或认证超时

**解决方案**:
```bash
# 检查端口51121是否被占用
lsof -i :51121

# 如果被占用，杀死进程
kill -9 <PID>

# 重试认证
openclaw models auth login --provider google-antigravity
```

### 问题2: "No API key found for provider google-antigravity"

**症状**: Main Agent自动回退到Gemini

**原因**: OAuth认证未完成或token过期

**解决方案**:
```bash
# 重新认证
openclaw models auth login --provider google-antigravity

# 或者注销后重新认证
openclaw models auth logout --provider google-antigravity
openclaw models auth login --provider google-antigravity
```

### 问题3: Claude Bot不响应

**症状**: Telegram Claude Bot没有回复

**检查步骤**:
```bash
# 1. 检查Gateway状态
openclaw gateway status

# 2. 查看日志
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 3. 检查Agent配置
openclaw agents list

# 4. 测试命令行
openclaw agent --agent fast --message "测试"

# 5. 重启Gateway
openclaw gateway restart
```

### 问题4: Google账号权限不足

**症状**: OAuth授权页面显示权限错误

**可能原因**:
- Google账号没有Cloud Code Assist访问权限
- Credits已用完
- 账号被限制

**解决方案**:
1. 检查Google Cloud Console的Credits余额
2. 确认账号有Code Assist服务的访问权限
3. 尝试使用其他Google账号

### 问题5: 模型响应错误或质量差

**检查是否使用了正确的模型**:
```bash
openclaw agent --agent main --message "请告诉我你的模型名称和版本"
```

如果显示Gemini而不是Claude，说明：
- OAuth认证未完成
- 或者已经触发了Fallback机制

---

## 📂 重要文件位置

| 文件路径 | 用途 |
|---------|------|
| `~/.openclaw/openclaw.json` | 主配置文件 |
| `~/.openclaw/openclaw.json.backup-before-claude-20260212` | 配置备份 |
| `~/.openclaw/.env` | Google Gemini API Key |
| `~/.openclaw/agents/main/agent/auth-profiles.json` | Main Agent认证信息 |
| `~/.openclaw/agents/fast/agent/auth-profiles.json` | Fast Bot认证信息 |
| `~/.openclaw/authenticate-claude.sh` | OAuth认证脚本 |
| `/tmp/openclaw/openclaw-2026-02-12.log` | 今日日志 |

---

## 🔄 如何恢复原配置

如果需要回到只使用Gemini的配置：

```bash
# 1. 恢复备份
cp ~/.openclaw/openclaw.json.backup-before-claude-20260212 ~/.openclaw/openclaw.json

# 2. 重启Gateway
openclaw gateway restart

# 3. （可选）禁用Antigravity插件
openclaw plugins disable google-antigravity-auth
openclaw gateway restart
```

---

## 📈 配置对比

### 修改前（仅Gemini）
| 项目 | 配置 |
|------|------|
| 默认模型 | Gemini 2.0 Flash |
| Pro Bot | Gemini 2.5 Pro |
| Fast Bot | Gemini 2.0 Flash |
| Fallback | Gemini 2.5 Pro |
| 认证 | Google API Key |
| 费用 | Google API免费额度 |

### 修改后（Claude + Gemini）
| 项目 | 配置 |
|------|------|
| 默认模型 | **Claude Sonnet 4.5** |
| Pro Bot | Gemini 2.5 Pro |
| Fast Bot | **Claude Sonnet 4.5** |
| Fallback | Gemini 2.5 Pro → Flash |
| 认证 | OAuth + API Key |
| 费用 | Google 300 Credits |

---

## 🎯 最终配置详情

### openclaw.json核心配置

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "google-antigravity/claude-sonnet-4-5",
        "fallbacks": [
          "google/gemini-2.5-pro",
          "google/gemini-2.0-flash"
        ]
      },
      "models": {
        "google-antigravity/claude-sonnet-4-5": {
          "alias": "Claude Sonnet 4.5"
        },
        "google/gemini-2.5-pro": {
          "alias": "Gemini Pro"
        },
        "google/gemini-2.0-flash": {
          "alias": "Gemini Flash"
        }
      }
    },
    "list": [
      {
        "id": "main",
        "default": true
      },
      {
        "id": "pro",
        "name": "Pro Bot",
        "model": "google/gemini-2.5-pro"
      },
      {
        "id": "fast",
        "name": "Claude Bot",
        "model": "google-antigravity/claude-sonnet-4-5"
      }
    ]
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      },
      "google-antigravity-auth": {
        "enabled": true
      }
    }
  }
}
```

---

## 📞 获取更多帮助

- **OpenClaw文档**: https://docs.openclaw.ai
- **故障排除**: https://docs.openclaw.ai/troubleshooting
- **Google Antigravity**: https://cloud.google.com/code-assist
- **Claude API文档**: https://docs.anthropic.com

---

**配置完成时间**: 2026-02-12  
**当前状态**: ✅ 配置完成，⏳ 等待OAuth认证  
**下一步**: 运行 `bash ~/.openclaw/authenticate-claude.sh` 完成OAuth认证

---

**提示**: 完成OAuth认证后，请再次运行测试命令验证Claude Sonnet 4.5是否正常工作！
