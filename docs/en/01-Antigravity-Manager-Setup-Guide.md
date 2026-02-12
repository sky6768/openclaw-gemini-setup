# Antigravity Manager Installation and Configuration Guide

**Installation Date**: February 12, 2026  
**Version**: Antigravity Tools v4.1.15  
**System**: Ubuntu 24.04 LTS

---

## ✅ Completed Steps

### 1. System Environment Check
- ✅ System: Ubuntu 24.04 LTS
- ✅ Port 8045 available
- ✅ OpenClaw Gateway running normally (port 18789)

### 2. Configuration Backup
- ✅ Backup location: `~/openclaw-backups/before-antigravity-20260212/`
- ✅ Backed up files:
  - `openclaw.json`
  - `.env`

### 3. Antigravity Manager Installation
- ✅ Download location: `~/下载/Antigravity.Tools_4.1.15_amd64.deb`
- ✅ Installation status: Successfully installed
- ✅ Executable file: `/usr/bin/antigravity_tools`
- ✅ Desktop icon: Created

---

## 🚀 Next Steps: Launch and Configure Antigravity Manager

### Step A: Launch the Application

**Method 1: Launch from Application Menu (Recommended)**
1. Open Application Menu (Show Applications)
2. Search for "Antigravity Tools"
3. Click the icon to launch

**Method 2: Launch from Terminal**
```bash
antigravity_tools &
```

### Step B: Initial Configuration

#### B.1 Set API Key

When launching for the first time, the application will ask you to set an API Key:

**Recommended Setting**:
```
API Key: sk-antigravity-openclaw-2026
```

**Important Notes**:
- This Key will be used for OpenClaw to access Antigravity Manager
- Please remember this Key, you will need it later in OpenClaw configuration
- It's recommended to set a complex but memorable Key

#### B.2 Enable API Proxy Service

1. Open Antigravity Tools application
2. Click "API Proxy" or "API 反代" in the left menu
3. **Enable Service**:
   - Turn on "Enable Proxy Service" switch
   - Confirm port is `8045`
   - Choose bind address `127.0.0.1` (local) or `0.0.0.0` (LAN)

4. **Verify Service Running**:
   ```bash
   curl http://127.0.0.1:8045/health
   ```
   Should return a response like: `{"status": "ok"}`

#### B.3 Add Google Account

This is the **most critical step**!

**Method: OAuth Authorization**

1. In Antigravity Tools, click "Accounts / 账号"
2. Click "Add Account" → "OAuth"
3. **Copy Authorization Link**:
   - Click "Generate Link" button
   - The authorization link will be automatically copied to clipboard
   - Or manually click "Copy" button

4. **Complete Authorization in Browser**:
   - Open your regular browser
   - Paste and visit the authorization link
   - Login with **a Google account that has 300 credits**
   - Click "Allow" to grant permissions

5. **Complete Authentication**:
   - Browser will redirect to `http://localhost:xxxxx/callback`
   - Shows "✅ Authorization successful!" or "授权成功!"
   - Return to Antigravity Tools application
   - The application will automatically save the account
   - If not completed automatically, click "I have authorized, continue" button

#### B.4 Verify Account Added Successfully

On the "Accounts / 账号" page, you should see:
- Your Google account displayed in the account list
- Quota information (if available)
- Account status showing "Active" or active

#### B.5 Configure Model Mapping (Optional)

If you need to customize model name mapping:

1. Go to "Model Router" or "模型路由" page
2. Add mapping rules, for example:
   - `claude-sonnet-4-5` → `claude-sonnet-4-5`
   - `claude-opus-4-5-thinking` → `claude-opus-4-5-thinking`

---

## 🔧 OpenClaw Configuration Modification

### Important Notes

After installing Antigravity Manager, OpenClaw's configuration needs to be modified to access Claude through Antigravity Manager instead of direct OAuth.

### Configuration Plan

I have prepared a configuration modification plan for you. **After completing the above Antigravity Manager configuration**, please let me know, and I will help you:

1. Modify `~/.openclaw/openclaw.json`
2. Configure OpenClaw to use Antigravity Manager as a proxy
3. Disable the original `google-antigravity-auth` plugin
4. Test if the integration is successful

---

## 📊 Architecture Explanation

### Before Modification (Current Configuration)
```
Claude Code CLI
      ↓
OpenClaw Gateway (18789)
      ↓
Google Antigravity OAuth (requires manual authentication)
      ↓
Google API (Claude)
```

### After Modification (Using Antigravity Manager)
```
Claude Code CLI
      ↓
OpenClaw Gateway (18789)
      ↓
Antigravity Manager (8045) ←── GUI Management
      ↓ (automatic account rotation)
Google API (Claude)
```

---

## ✅ Checklist

Before continuing, please confirm:

- [ ] Antigravity Tools application is launched
- [ ] API proxy service is enabled (port 8045)
- [ ] At least one Google account has been added
- [ ] Account OAuth authorization successful
- [ ] API Key has been set and remembered (e.g., sk-antigravity-openclaw-2026)
- [ ] API service is accessible (curl http://127.0.0.1:8045/health returns normally)

---

## 🔑 Important Information Record

Please record the following information, you will need it when configuring OpenClaw later:

**Antigravity Manager Configuration**:
- API Key: `____________________________`
- Service Port: `8045`
- Bind Address: `127.0.0.1` or `0.0.0.0`
- Number of Accounts Added: `____`

---

## 🆘 Common Issues

### Q1: Application Cannot Start
```bash
# Launch from terminal to view error messages
antigravity_tools
```

### Q2: OAuth Authorization Failed
- Ensure Antigravity Tools application is running
- Check if callback port is occupied
- Try using incognito mode browser
- Confirm Google account has Code Assist permissions

### Q3: Port 8045 is Occupied
```bash
# Check port usage
lsof -i :8045

# Kill the occupying process
sudo kill -9 <PID>
```

### Q4: API Service Not Responding
```bash
# Check Antigravity service status
curl -v http://127.0.0.1:8045/health

# View Antigravity logs
# Check in the application's settings or log page
```

---

## 📞 Next Steps

**After completing the above configuration**, please let me know in the conversation:

1. "Antigravity Manager is configured"
2. Or "Encountered problem: [specific problem description]"

I will continue to help you:
- Modify OpenClaw configuration
- Integrate the two systems
- Perform comprehensive testing
- Ensure Claude Sonnet 4.5 works normally

---

**Configuration Completion Time**: To be completed  
**Next Step**: Launch Antigravity Tools and add Google account
