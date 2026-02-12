# OpenClaw + Claude Sonnet 4.5 via Antigravity Manager

# OpenClaw + Claude Sonnet 4.5 通过 Antigravity Manager

[![GitHub stars](https://img.shields.io/github/stars/sky6768/openclaw-gemini-setup?style=social)](https://github.com/sky6768/openclaw-gemini-setup)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.2.9-blue)](https://openclaw.ai)
[![Claude](https://img.shields.io/badge/Claude-Sonnet%204.5-orange)](https://www.anthropic.com/claude)
[![Antigravity Manager](https://img.shields.io/badge/Antigravity%20Manager-v4.1.15-green)](https://github.com/antigravity-tools)

[English](#english) | [中文](#中文)

---

<a name="english"></a>

## English

### 📖 Overview

A complete guide to configure **Claude Sonnet 4.5** with **OpenClaw** via **Antigravity Manager**, featuring graphical OAuth management, multi-account pooling, and intelligent fallback mechanisms.

OpenClaw is a personal AI assistant that runs on your own devices. This guide shows you how to integrate Claude Sonnet 4.5 through Google Antigravity API using Antigravity Manager for seamless account management.

### ✨ Features

- ✅ **Claude Sonnet 4.5 Integration** - Access Claude via Google Antigravity API
- ✅ **Antigravity Manager** - GUI for OAuth and multi-account management  
- ✅ **Multi-Account Pooling** - Automatic rotation across multiple Google accounts
- ✅ **Cost Optimization** - 40% cheaper than Opus 4.5 ($3/$15 vs $5/$25 per million tokens)
- ✅ **Intelligent Fallback** - Claude → Gemini 2.5 Pro → Gemini 2.0 Flash
- ✅ **Bilingual Documentation** - Complete Chinese and English docs
- ✅ **Fully Tested** - All configurations verified and working
- ✅ **No Manual OAuth** - Antigravity Manager handles authentication in GUI

### 🚀 Quick Start

> **NEW**: This guide now includes Claude Sonnet 4.5 setup via Antigravity Manager! See the [Claude Setup](#claude-setup) section below.

#### Option 1: Claude Sonnet 4.5 via Antigravity Manager (Recommended)

##### Prerequisites

- OpenClaw installed (version 2026.2.9 or later)
- Node.js ≥ 22
- Ubuntu 24.04 LTS (or other Linux distribution)
- Google account with Cloud Code Assist access and Credits

##### Installation

1. **Install Antigravity Manager:**
   ```bash
   wget https://github.com/antigravity-tools/antigravity-manager/releases/download/v4.1.15/Antigravity.Tools_4.1.15_amd64.deb
   sudo dpkg -i Antigravity.Tools_4.1.15_amd64.deb
   antigravity_tools &
   ```

2. **Configure Antigravity Manager:**
   - Set API Key: `sk-antigravity-openclaw-2026`
   - Enable API Proxy Service on port `8045`
   - Add Google account via OAuth (in GUI)
   - Verify: `curl http://127.0.0.1:8045/health`

3. **Configure OpenClaw:**
   Edit `~/.openclaw/openclaw.json`:
   ```json
   {
     "agents": {
       "defaults": {
         "model": {
           "primary": "claude-sonnet-4-5",
           "fallbacks": ["google/gemini-2.5-pro", "google/gemini-2.0-flash"]
         }
       }
     },
     "env": {
       "ANTHROPIC_API_KEY": "sk-antigravity-openclaw-2026",
       "ANTHROPIC_BASE_URL": "http://127.0.0.1:8045"
     }
   }
   ```

4. **Restart and test:**
   ```bash
   openclaw gateway restart
   openclaw agent --message "Hello! Please confirm you are Claude Sonnet 4.5"
   ```

📖 **Full Guide**: See [docs/en/](docs/en/) for detailed instructions.

---

#### Option 2: Google Gemini API (Original Method)

##### Prerequisites

- OpenClaw installed (version 2026.2.9 or later)
- Node.js ≥ 22
- A Google Gemini API key ([Get one here](https://makersuite.google.com/app/apikey))

#### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/sky6768/openclaw-gemini-setup.git
   cd openclaw-gemini-setup
   ```

2. **Run the automated setup script:**
   ```bash
   chmod +x scripts/setup-gemini.sh
   ./scripts/setup-gemini.sh
   ```

3. **Enter your Gemini API key when prompted**

4. **Verify the setup:**
   ```bash
   ./scripts/verify-setup.sh
   ```

That's it! Your OpenClaw is now configured to use Gemini API.

### 🔧 Manual Installation

If you prefer manual setup, follow the detailed guide in [docs/installation-guide.md](docs/installation-guide.md).

#### Step 1: Configure Environment Variables

Copy the template and edit with your API key:

```bash
cp config/.env.example ~/.openclaw/.env
nano ~/.openclaw/.env
```

Set your API key:
```bash
GEMINI_API_KEY=your-api-key-here
GOOGLE_API_KEY=your-api-key-here
```

#### Step 2: Configure Agent Authentication

Create the agent authentication file:

```bash
mkdir -p ~/.openclaw/agents/main/agent
cp config/auth-profiles.json.example ~/.openclaw/agents/main/agent/auth-profiles.json
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

Update the API key in the JSON file:
```json
{
  "profiles": {
    "google": {
      "provider": "google",
      "auth": "api-key",
      "apiKey": "your-api-key-here"
    }
  }
}
```

#### Step 3: Update OpenClaw Configuration

Edit `~/.openclaw/openclaw.json` and add:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-2.0-flash"
      }
    }
  },
  "models": {
    "mode": "merge"
  }
}
```

#### Step 4: Restart Gateway Service

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
openclaw gateway restart
```

#### Step 5: Test the Configuration

```bash
openclaw agent --agent main --message "Hello! Please confirm you're using Gemini."
```

### 🔑 API Key Management

#### Updating Your API Key

Use the provided script to update your API key safely:

```bash
./scripts/update-api-key.sh
```

This will:
- ✅ Update both configuration files (`.env` and `auth-profiles.json`)
- ✅ Backup old configurations
- ✅ Restart the Gateway service
- ✅ Verify the new setup

#### Security Best Practices

⚠️ **Important Security Notes:**

1. **Never commit your actual API keys to Git**
2. Always use the `.example` template files
3. Keep your `.env` and `auth-profiles.json` files private
4. Rotate your API keys periodically
5. Use environment-specific keys for development/production

### 🛠️ Troubleshooting

#### Common Issues

**1. "No API key found for provider 'google'"**

This usually means the agent authentication file is missing or not properly configured.

**Solution:**
```bash
# Check if the file exists
ls ~/.openclaw/agents/main/agent/auth-profiles.json

# If missing, create it:
mkdir -p ~/.openclaw/agents/main/agent
cp config/auth-profiles.json.example ~/.openclaw/agents/main/agent/auth-profiles.json

# Edit and add your API key
nano ~/.openclaw/agents/main/agent/auth-profiles.json

# Restart gateway
openclaw gateway restart
```

**2. "Gateway agent failed; falling back to embedded"**

This means the Gateway service couldn't find the API key but the embedded mode (using environment variables) worked.

**Solution:** Configure the agent authentication file as shown above.

**3. Model not responding in Chat/Web UI**

**Solution:**
```bash
# 1. Verify gateway is running
openclaw gateway status

# 2. Check logs for errors
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 3. Restart gateway
openclaw gateway restart
```

For more troubleshooting tips, see [docs/troubleshooting.md](docs/troubleshooting.md).

### 📂 Project Structure

```
openclaw-gemini-setup/
├── README.md                          # This file (bilingual)
├── scripts/
│   ├── setup-gemini.sh                # Automated setup script
│   ├── update-api-key.sh              # API key update script
│   ├── verify-setup.sh                # Configuration verification
│   └── start-openclaw.sh              # Convenience startup script
├── config/
│   ├── .env.example                   # Environment variables template
│   ├── auth-profiles.json.example     # Agent auth template
│   └── openclaw.json.example          # OpenClaw config template
├── docs/
│   ├── installation-guide.md          # Detailed installation guide
│   ├── telegram-dual-bot-setup.md     # Telegram dual-bot configuration (NEW)
│   ├── troubleshooting.md             # Troubleshooting guide
│   └── api-key-management.md          # API key best practices
├── .gitignore                         # Git ignore rules
└── LICENSE                            # MIT License
```

### 📚 Documentation

#### Claude + Antigravity Manager Setup (NEW)
- [01 - Antigravity Manager Setup Guide](docs/en/01-Antigravity-Manager-Setup-Guide.md) - Install and configure Antigravity Manager
- [02 - Claude Sonnet 4.5 Setup Guide](docs/en/02-Claude-Sonnet-4.5-Setup-Guide.md) - Configure OpenClaw for Claude
- [03 - Test Report](docs/en/03-Test-Report.md) - Complete test results and verification
- [04 - Quick Reference](docs/en/04-Quick-Reference.md) - Quick commands and troubleshooting

#### Gemini API Setup (Original)
- [Installation Guide](docs/installation-guide.md) - Detailed setup instructions
- [Telegram Dual-Bot Setup](docs/telegram-dual-bot-setup.md) - Configure two bots with different models (Flash & Pro)
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [API Key Management](docs/api-key-management.md) - Security best practices
- [Contributing Guide](CONTRIBUTING.md) - How to contribute

### 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 🙏 Acknowledgments

- [OpenClaw](https://openclaw.ai) - Personal AI assistant framework
- [Google Gemini](https://ai.google.dev) - AI model provider

### 📧 Contact

- GitHub: [@sky6768](https://github.com/sky6768)
- Issues: [GitHub Issues](https://github.com/sky6768/openclaw-gemini-setup/issues)

---

<a name="中文"></a>

## 中文

### 📖 概述

这是一个完整的指南，帮助您通过 **Antigravity Manager** 在 **OpenClaw** 上配置 **Claude Sonnet 4.5** 模型，具备图形化 OAuth 管理、多账号池和智能回退机制。

OpenClaw 是一个运行在您自己设备上的个人 AI 助手。本指南将向您展示如何通过 Antigravity Manager 使用 Google Antigravity API 集成 Claude Sonnet 4.5，实现无缝账号管理。

### ✨ 功能特性

- ✅ **Claude Sonnet 4.5 集成** - 通过 Google Antigravity API 访问 Claude
- ✅ **Antigravity Manager** - 图形化 OAuth 和多账号管理
- ✅ **多账号池** - 多个 Google 账号自动轮询
- ✅ **成本优化** - 比 Opus 4.5 便宜 40%（$3/$15 vs $5/$25 每百万 tokens）
- ✅ **智能回退** - Claude → Gemini 2.5 Pro → Gemini 2.0 Flash
- ✅ **双语文档** - 完整的中英文文档
- ✅ **完全测试** - 所有配置已验证并正常工作
- ✅ **无需手动 OAuth** - Antigravity Manager 在图形界面处理认证

### 🚀 快速开始

> **新增**: 本指南现在包含通过 Antigravity Manager 配置 Claude Sonnet 4.5！请参阅下方的 [Claude 配置](#claude-配置)部分。

#### 选项 1: 通过 Antigravity Manager 使用 Claude Sonnet 4.5（推荐）

##### 前置要求

- 已安装 OpenClaw（版本 2026.2.9 或更高）
- Node.js ≥ 22
- Ubuntu 24.04 LTS（或其他 Linux 发行版）
- 有 Cloud Code Assist 访问权限和 Credits 的 Google 账号

##### 安装步骤

1. **安装 Antigravity Manager：**
   ```bash
   wget https://github.com/antigravity-tools/antigravity-manager/releases/download/v4.1.15/Antigravity.Tools_4.1.15_amd64.deb
   sudo dpkg -i Antigravity.Tools_4.1.15_amd64.deb
   antigravity_tools &
   ```

2. **配置 Antigravity Manager：**
   - 设置 API Key: `sk-antigravity-openclaw-2026`
   - 在端口 `8045` 启用 API 反代服务
   - 通过 OAuth 添加 Google 账号（在图形界面中）
   - 验证: `curl http://127.0.0.1:8045/health`

3. **配置 OpenClaw：**
   编辑 `~/.openclaw/openclaw.json`:
   ```json
   {
     "agents": {
       "defaults": {
         "model": {
           "primary": "claude-sonnet-4-5",
           "fallbacks": ["google/gemini-2.5-pro", "google/gemini-2.0-flash"]
         }
       }
     },
     "env": {
       "ANTHROPIC_API_KEY": "sk-antigravity-openclaw-2026",
       "ANTHROPIC_BASE_URL": "http://127.0.0.1:8045"
     }
   }
   ```

4. **重启并测试：**
   ```bash
   openclaw gateway restart
   openclaw agent --message "你好！请确认你是 Claude Sonnet 4.5"
   ```

📖 **完整指南**: 详见 [docs/zh-CN/](docs/zh-CN/) 获取详细说明。

---

#### 选项 2: Google Gemini API（原始方法）

##### 前置要求

- 已安装 OpenClaw（版本 2026.2.9 或更高）
- Node.js ≥ 22
- Google Gemini API Key（[在此获取](https://makersuite.google.com/app/apikey)）

#### 安装步骤

1. **克隆本仓库：**
   ```bash
   git clone https://github.com/sky6768/openclaw-gemini-setup.git
   cd openclaw-gemini-setup
   ```

2. **运行自动化配置脚本：**
   ```bash
   chmod +x scripts/setup-gemini.sh
   ./scripts/setup-gemini.sh
   ```

3. **按提示输入您的 Gemini API Key**

4. **验证配置：**
   ```bash
   ./scripts/verify-setup.sh
   ```

完成！您的 OpenClaw 现在已配置为使用 Gemini API。

### 🔧 手动安装

如果您prefer手动设置，请参阅 [docs/installation-guide.md](docs/installation-guide.md) 中的详细指南。

#### 步骤 1：配置环境变量

复制模板并编辑您的 API Key：

```bash
cp config/.env.example ~/.openclaw/.env
nano ~/.openclaw/.env
```

设置您的 API Key：
```bash
GEMINI_API_KEY=你的API密钥
GOOGLE_API_KEY=你的API密钥
```

#### 步骤 2：配置 Agent 认证

创建 agent 认证文件：

```bash
mkdir -p ~/.openclaw/agents/main/agent
cp config/auth-profiles.json.example ~/.openclaw/agents/main/agent/auth-profiles.json
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

在 JSON 文件中更新 API Key：
```json
{
  "profiles": {
    "google": {
      "provider": "google",
      "auth": "api-key",
      "apiKey": "你的API密钥"
    }
  }
}
```

#### 步骤 3：更新 OpenClaw 配置

编辑 `~/.openclaw/openclaw.json` 并添加：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-2.0-flash"
      }
    }
  },
  "models": {
    "mode": "merge"
  }
}
```

#### 步骤 4：重启 Gateway 服务

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
openclaw gateway restart
```

#### 步骤 5：测试配置

```bash
openclaw agent --agent main --message "你好！请确认你正在使用 Gemini。"
```

### 🔑 API Key 管理

#### 更新您的 API Key

使用提供的脚本安全地更新您的 API Key：

```bash
./scripts/update-api-key.sh
```

脚本将：
- ✅ 更新两个配置文件（`.env` 和 `auth-profiles.json`）
- ✅ 备份旧配置
- ✅ 重启 Gateway 服务
- ✅ 验证新配置

#### 安全最佳实践

⚠️ **重要安全提示：**

1. **永远不要将实际的 API Key 提交到 Git**
2. 始终使用 `.example` 模板文件
3. 保持您的 `.env` 和 `auth-profiles.json` 文件私密
4. 定期轮换您的 API Key
5. 为开发/生产环境使用不同的 Key

### 🛠️ 故障排除

#### 常见问题

**1. "No API key found for provider 'google'"（未找到 google 提供商的 API Key）**

这通常意味着 agent 认证文件丢失或配置不正确。

**解决方案：**
```bash
# 检查文件是否存在
ls ~/.openclaw/agents/main/agent/auth-profiles.json

# 如果丢失，创建它：
mkdir -p ~/.openclaw/agents/main/agent
cp config/auth-profiles.json.example ~/.openclaw/agents/main/agent/auth-profiles.json

# 编辑并添加您的 API Key
nano ~/.openclaw/agents/main/agent/auth-profiles.json

# 重启 gateway
openclaw gateway restart
```

**2. "Gateway agent failed; falling back to embedded"（Gateway agent 失败，回退到嵌入模式）**

这意味着 Gateway 服务无法找到 API Key，但嵌入模式（使用环境变量）工作正常。

**解决方案：** 如上所示配置 agent 认证文件。

**3. Chat/Web UI 中模型无响应**

**解决方案：**
```bash
# 1. 验证 gateway 正在运行
openclaw gateway status

# 2. 检查日志中的错误
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 3. 重启 gateway
openclaw gateway restart
```

更多故障排除技巧，请参阅 [docs/troubleshooting.md](docs/troubleshooting.md)。

### 📂 项目结构

```
openclaw-gemini-setup/
├── README.md                          # 本文件（双语）
├── scripts/
│   ├── setup-gemini.sh                # 自动化配置脚本
│   ├── update-api-key.sh              # API Key 更新脚本
│   ├── verify-setup.sh                # 配置验证脚本
│   └── start-openclaw.sh              # 便捷启动脚本
├── config/
│   ├── .env.example                   # 环境变量模板
│   ├── auth-profiles.json.example     # Agent 认证模板
│   └── openclaw.json.example          # OpenClaw 配置模板
├── docs/
│   ├── installation-guide.md          # 详细安装指南
│   ├── troubleshooting.md             # 故障排除指南
│   └── api-key-management.md          # API Key 最佳实践
├── .gitignore                         # Git 忽略规则
└── LICENSE                            # MIT 许可证
```

### 📚 文档

#### Claude + Antigravity Manager 配置（新增）
- [01 - Antigravity Manager 安装配置指南](docs/zh-CN/01-Antigravity-Manager安装配置指南.md) - 安装和配置 Antigravity Manager
- [02 - Claude Sonnet 4.5 配置指南](docs/zh-CN/02-Claude-Sonnet-4.5配置指南.md) - 为 Claude 配置 OpenClaw
- [03 - 测试报告](docs/zh-CN/03-测试报告.md) - 完整测试结果和验证
- [04 - 快速参考](docs/zh-CN/04-快速参考.md) - 快速命令和故障排除

#### Gemini API 配置（原有）
- [安装指南](docs/installation-guide.md) - 详细设置说明
- [Telegram 双 Bot 配置指南](docs/telegram-dual-bot-setup.md) - 配置两个使用不同模型的 Bot（Flash 和 Pro）
- [故障排除](docs/troubleshooting.md) - 常见问题和解决方案
- [API Key 管理](docs/api-key-management.md) - 安全最佳实践
- [贡献指南](CONTRIBUTING.md) - 如何贡献

### 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m '添加某个很棒的特性'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

### 📄 许可证

本项目采用 MIT 许可证 - 详情请参阅 [LICENSE](LICENSE) 文件。

### 🙏 致谢

- [OpenClaw](https://openclaw.ai) - 个人 AI 助手框架
- [Google Gemini](https://ai.google.dev) - AI 模型提供商

### 📧 联系方式

- GitHub: [@sky6768](https://github.com/sky6768)
- Issues: [GitHub Issues](https://github.com/sky6768/openclaw-gemini-setup/issues)

---

**⭐ 如果这个项目对您有帮助，请给它一个星标！**

**⭐ If this project helps you, please give it a star!**
