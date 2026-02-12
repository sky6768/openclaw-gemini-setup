# Antigravity Manager 安装和配置完成指南

**安装时间**: 2026年2月12日  
**版本**: Antigravity Tools v4.1.15  
**系统**: Ubuntu 24.04 LTS

---

## ✅ 已完成的步骤

### 1. 系统环境检查
- ✅ 系统: Ubuntu 24.04 LTS
- ✅ 端口8045空闲可用
- ✅ OpenClaw Gateway运行正常（端口18789）

### 2. 配置备份
- ✅ 备份位置: `~/openclaw-backups/before-antigravity-20260212/`
- ✅ 已备份文件:
  - `openclaw.json`
  - `.env`

### 3. Antigravity Manager安装
- ✅ 下载位置: `~/下载/Antigravity.Tools_4.1.15_amd64.deb`
- ✅ 安装状态: 已成功安装
- ✅ 可执行文件: `/usr/bin/antigravity_tools`
- ✅ 桌面图标: 已创建

---

## 🚀 下一步：启动和配置Antigravity Manager

### 步骤A：启动应用程序

**方式1：从应用菜单启动（推荐）**
1. 打开应用菜单（Show Applications）
2. 搜索 "Antigravity Tools"
3. 点击图标启动

**方式2：从终端启动**
```bash
antigravity_tools &
```

### 步骤B：首次配置

#### B.1 设置API Key

首次启动时，应用会要求您设置API Key：

**推荐设置**:
```
API Key: sk-antigravity-openclaw-2026
```

**重要提示**:
- 这个Key将用于OpenClaw访问Antigravity Manager
- 请记住这个Key，稍后需要在OpenClaw配置中使用
- 建议设置一个复杂但易记的Key

#### B.2 启用API反代服务

1. 打开Antigravity Tools应用
2. 点击左侧菜单的 "API 反代" 或 "API Proxy"
3. **启用服务**：
   - 打开 "启用代理服务" 开关
   - 确认端口为 `8045`
   - 绑定地址选择 `127.0.0.1`（本地）或 `0.0.0.0`（局域网）

4. **验证服务运行**：
   ```bash
   curl http://127.0.0.1:8045/health
   ```
   应该返回类似：`{"status": "ok"}` 的响应

#### B.3 添加Google账号

这是**最关键的步骤**！

**方法：OAuth授权**

1. 在Antigravity Tools中，点击 "Accounts / 账号"
2. 点击 "添加账号" → "OAuth"
3. **复制授权链接**：
   - 点击"生成链接"按钮
   - 授权链接会自动复制到剪贴板
   - 或手动点击"复制"按钮

4. **在浏览器中完成授权**：
   - 打开您常用的浏览器
   - 粘贴并访问授权链接
   - 使用**有300 credits的Google账号**登录
   - 点击 "允许" 或 "Allow" 授予权限

5. **完成认证**：
   - 浏览器会重定向到 `http://localhost:xxxxx/callback`
   - 显示 "✅ 授权成功!" 或 "Authorization successful"
   - 返回Antigravity Tools应用
   - 应用会自动保存账号
   - 如未自动完成，点击 "我已授权，继续" 按钮

#### B.4 验证账号添加成功

在 "Accounts / 账号" 页面，您应该看到：
- 账号列表中显示您的Google账号
- 配额信息（如有）
- 账号状态显示为 "Active" 或活跃

#### B.5 配置模型映射（可选）

如果需要自定义模型名称映射：

1. 进入 "模型路由" 或 "Model Router" 页面
2. 添加映射规则，例如：
   - `claude-sonnet-4-5` → `claude-sonnet-4-5`
   - `claude-opus-4-5-thinking` → `claude-opus-4-5-thinking`

---

## 🔧 OpenClaw配置修改

### 重要说明

安装Antigravity Manager后，OpenClaw的配置需要修改为通过Antigravity Manager访问Claude，而不是直接OAuth。

### 配置方案

我已经为您准备了配置修改方案。**在完成上述Antigravity Manager配置后**，请告诉我，我将帮您：

1. 修改 `~/.openclaw/openclaw.json`
2. 配置OpenClaw使用Antigravity Manager作为代理
3. 禁用原有的`google-antigravity-auth`插件
4. 测试集成是否成功

---

## 📊 架构说明

### 修改前（当前配置）
```
Claude Code CLI
      ↓
OpenClaw Gateway (18789)
      ↓
Google Antigravity OAuth (需要手动认证)
      ↓
Google API (Claude)
```

### 修改后（使用Antigravity Manager）
```
Claude Code CLI
      ↓
OpenClaw Gateway (18789)
      ↓
Antigravity Manager (8045) ←── 图形界面管理
      ↓ (自动账号轮询)
Google API (Claude)
```

---

## ✅ 检查清单

在继续之前，请确认：

- [ ] Antigravity Tools应用已启动
- [ ] API反代服务已启用（端口8045）
- [ ] 至少添加了一个Google账号
- [ ] 账号OAuth授权成功
- [ ] 已设置并记住API Key（例如：sk-antigravity-openclaw-2026）
- [ ] API服务可以访问（curl http://127.0.0.1:8045/health 返回正常）

---

## 🔑 重要信息记录

请记录以下信息，稍后配置OpenClaw时需要：

**Antigravity Manager配置**:
- API Key: `____________________________`
- 服务端口: `8045`
- 绑定地址: `127.0.0.1` 或 `0.0.0.0`
- 已添加账号数量: `____`

---

## 🆘 常见问题

### Q1: 应用无法启动
```bash
# 从终端启动查看错误信息
antigravity_tools
```

### Q2: OAuth授权失败
- 确保Antigravity Tools应用正在运行
- 检查回调端口是否被占用
- 尝试使用无痕模式浏览器
- 确认Google账号有Code Assist权限

### Q3: 端口8045被占用
```bash
# 检查端口占用
lsof -i :8045

# 结束占用进程
sudo kill -9 <PID>
```

### Q4: API服务无响应
```bash
# 检查Antigravity服务状态
curl -v http://127.0.0.1:8045/health

# 查看Antigravity日志
# 在应用的设置或日志页面查看
```

---

## 📞 下一步

**完成上述配置后**，请在对话中告诉我：

1. "Antigravity Manager已配置好"
2. 或 "遇到问题：[具体问题描述]"

我将继续帮您：
- 修改OpenClaw配置
- 集成两个系统
- 进行完整测试
- 确保Claude Sonnet 4.5正常工作

---

**配置完成时间**: 待完成  
**下一步**: 启动Antigravity Tools并添加Google账号
