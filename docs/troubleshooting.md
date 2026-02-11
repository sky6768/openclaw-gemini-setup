# Troubleshooting Guide / 故障排除指南

[English](#english) | [中文](#中文)

---

<a name="english"></a>

## English

### Common Issues and Solutions

#### 1. "No API key found for provider 'google'"

**Symptom:** Error message when trying to use OpenClaw in Chat/Web UI mode.

**Cause:** The agent authentication file (`auth-profiles.json`) is missing or not properly configured.

**Solution:**

```bash
# Create the auth file
mkdir -p ~/.openclaw/agents/main/agent

# Copy the template
cp config/auth-profiles.json.example ~/.openclaw/agents/main/agent/auth-profiles.json

# Edit and add your API key
nano ~/.openclaw/agents/main/agent/auth-profiles.json

# Restart gateway
openclaw gateway restart
```

#### 2. "Gateway agent failed; falling back to embedded"

**Symptom:** Gateway service can't find API key, but command-line mode works.

**Cause:** Environment variables are set (`.env`) but agent authentication file is not configured.

**Solution:** Configure `auth-profiles.json` as shown in Issue #1.

#### 3. Model not responding in Chat/Web UI

**Symptom:** No response when sending messages in the web interface.

**Diagnosis Steps:**

```bash
# 1. Check if gateway is running
openclaw gateway status

# 2. Check logs
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 3. Verify configuration
./scripts/verify-setup.sh
```

**Solution:**

```bash
# Restart gateway
openclaw gateway restart

# If still not working, reconfigure
./scripts/setup-gemini.sh
```

#### 4. API Key format error

**Symptom:** "Invalid API key" or authentication errors.

**Cause:** API key is incorrect or malformed.

**Solution:**

- Verify your API key at: https://makersuite.google.com/app/apikey
- Gemini API keys usually start with `AIza`
- Make sure there are no extra spaces or quotes
- Use the update script: `./scripts/update-api-key.sh`

#### 5. Command not found: openclaw

**Symptom:** Shell can't find the `openclaw` command.

**Solution:**

```bash
# Add to PATH temporarily
export PATH="$HOME/.npm-global/bin:$PATH"

# Add permanently (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### 6. Permission denied errors

**Symptom:** Can't create or modify configuration files.

**Solution:**

```bash
# Fix permissions for OpenClaw directory
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/.env
chmod 600 ~/.openclaw/agents/main/agent/auth-profiles.json
```

### Verification Checklist

Run the verification script to check your setup:

```bash
./scripts/verify-setup.sh
```

The script checks:
- ✅ OpenClaw installation
- ✅ Environment variables (`.env`)
- ✅ Agent authentication file
- ✅ OpenClaw configuration
- ✅ Gateway service status
- ✅ API connection test

### Getting Help

If you're still experiencing issues:

1. Run the verification script and share the output
2. Check the logs: `tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log`
3. Open an issue on GitHub: https://github.com/sky6768/openclaw-gemini-setup/issues

---

<a name="中文"></a>

## 中文

### 常见问题和解决方案

#### 1. "No API key found for provider 'google'"（未找到 google 提供商的 API Key）

**症状：** 在 Chat/Web UI 模式下使用 OpenClaw 时出现错误消息。

**原因：** Agent 认证文件（`auth-profiles.json`）丢失或配置不正确。

**解决方案：**

```bash
# 创建认证文件
mkdir -p ~/.openclaw/agents/main/agent

# 复制模板
cp config/auth-profiles.json.example ~/.openclaw/agents/main/agent/auth-profiles.json

# 编辑并添加您的 API Key
nano ~/.openclaw/agents/main/agent/auth-profiles.json

# 重启 gateway
openclaw gateway restart
```

#### 2. "Gateway agent failed; falling back to embedded"

**症状：** Gateway 服务找不到 API Key，但命令行模式正常工作。

**原因：** 环境变量已设置（`.env`），但 agent 认证文件未配置。

**解决方案：** 如问题 #1 所示配置 `auth-profiles.json`。

#### 3. Chat/Web UI 中模型无响应

**症状：** 在 Web 界面发送消息时没有响应。

**诊断步骤：**

```bash
# 1. 检查 gateway 是否运行
openclaw gateway status

# 2. 查看日志
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 3. 验证配置
./scripts/verify-setup.sh
```

**解决方案：**

```bash
# 重启 gateway
openclaw gateway restart

# 如果仍然不工作，重新配置
./scripts/setup-gemini.sh
```

#### 4. API Key 格式错误

**症状：** "Invalid API key" 或认证错误。

**原因：** API Key 不正确或格式错误。

**解决方案：**

- 在此验证您的 API Key：https://makersuite.google.com/app/apikey
- Gemini API Key 通常以 `AIza` 开头
- 确保没有多余的空格或引号
- 使用更新脚本：`./scripts/update-api-key.sh`

#### 5. 命令未找到：openclaw

**症状：** Shell 找不到 `openclaw` 命令。

**解决方案：**

```bash
# 临时添加到 PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# 永久添加（添加到 ~/.bashrc 或 ~/.zshrc）
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### 6. 权限被拒绝错误

**症状：** 无法创建或修改配置文件。

**解决方案：**

```bash
# 修复 OpenClaw 目录权限
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/.env
chmod 600 ~/.openclaw/agents/main/agent/auth-profiles.json
```

### 验证清单

运行验证脚本检查您的设置：

```bash
./scripts/verify-setup.sh
```

脚本检查：
- ✅ OpenClaw 安装
- ✅ 环境变量（`.env`）
- ✅ Agent 认证文件
- ✅ OpenClaw 配置
- ✅ Gateway 服务状态
- ✅ API 连接测试

### 获取帮助

如果您仍然遇到问题：

1. 运行验证脚本并分享输出
2. 检查日志：`tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log`
3. 在 GitHub 上开启 issue：https://github.com/sky6768/openclaw-gemini-setup/issues
