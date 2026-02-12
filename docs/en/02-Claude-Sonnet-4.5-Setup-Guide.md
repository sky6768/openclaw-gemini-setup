# Claude Sonnet 4.5 Setup Guide

**Setup Date**: 2026-02-12  
**Setup Status**: ✅ Configuration Complete, ⏳ Awaiting OAuth Authentication

---

## ✅ Completed Configuration

### 1. Model Configuration
- ✅ Default model set to `google-antigravity/claude-sonnet-4-5`
- ✅ Fallback mechanism configured: Claude Sonnet 4.5 → Gemini 2.5 Pro → Gemini 2.0 Flash
- ✅ Google Antigravity Auth plugin enabled

### 2. Agent Configuration

| Agent ID | Name | Model | Status |
|----------|------|------|------|
| **main** (default) | Main Agent | Claude Sonnet 4.5 | ⏳ Needs OAuth |
| **pro** | Pro Bot | Gemini 2.5 Pro | ✅ Working |
| **fast** | Claude Bot | Claude Sonnet 4.5 | ⏳ Needs OAuth |

### 3. Telegram Bot Configuration

- **Pro Bot** (token: 8130...NLA)
  - Display name: "Pro Bot (Gemini 2.5 Pro)"
  - Model: Gemini 2.5 Pro
  - Status: ✅ Available

- **Claude Bot** (token: 8468...vOM)  
  - Display name: "Claude Bot (Sonnet 4.5)"
  - Model: Claude Sonnet 4.5
  - Status: ⏳ Needs OAuth Authentication

### 4. Test Results

✅ **Gemini Pro Bot Test Passed**
```bash
$ openclaw agent --agent pro --message "你好！"
Response: Normal, Gemini 2.5 Pro working correctly
```

⏳ **Claude Sonnet 4.5 Needs Authentication**
```bash
$ openclaw agent --agent main --message "你好！"
Status: Automatically fell back to Gemini Pro (Fallback mechanism working)
Reason: No API key found for provider "google-antigravity"
```

---

## 🔑 Next Step: Complete OAuth Authentication

### Why OAuth Authentication is Required?

Google Antigravity uses OAuth 2.0 authentication instead of a simple API Key. This is because it accesses Claude models through the Google Cloud Code Assist service, requiring a higher level of authorization.

### Authentication Methods

There are two ways to complete OAuth authentication:

#### **Method 1: Using Automated Script (Recommended)**

I've created an authentication script for you:

```bash
bash ~/.openclaw/authenticate-claude.sh
```

The script will:
1. Guide you through the OAuth flow
2. Automatically open a browser for Google login
3. Verify authentication status
4. Provide test commands

#### **Method 2: Manual Authentication**

```bash
# 1. Set PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# 2. Start OAuth authentication
openclaw models auth login --provider google-antigravity

# 3. Follow the prompts to complete browser authorization
#    - Visit the generated URL (may open automatically)
#    - Log in with your Google account that has 300 credits
#    - Authorize OpenClaw to access Cloud Code Assist
#    - Browser redirects to http://localhost:51121/callback
#    - See "Authentication successful" message

# 4. Verify authentication status
openclaw models list | grep claude-sonnet
```

### OAuth Authentication Process Explained

1. **Execute Command**
   ```
   openclaw models auth login --provider google-antigravity
   ```

2. **Generate Authorization URL**
   - OpenClaw generates a Google OAuth URL
   - URL contains required permission scopes and callback address

3. **Browser Authorization**
   - Browser opens automatically (or manually visit URL)
   - Select your Google account (the one with 300 credits)
   - Review permission request and click "Allow"

4. **Callback Handling**
   - Google redirects to `http://localhost:51121/callback?code=...`
   - OpenClaw's local server receives the authorization code
   - Exchanges authorization code for access token

5. **Save Authentication Info**
   - Token saved to `~/.openclaw/agents/main/agent/auth-profiles.json`
   - Also saved to other Agent's auth-profiles.json (like fast)

6. **Complete**
   - Terminal displays "Authentication successful"
   - Now you can use Claude Sonnet 4.5 model

---

## ✅ Verification Steps After Authentication

### 1. Check Model Authentication Status

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
openclaw models list
```

Expected output:
```
Model                                      Input      Ctx      Local Auth  Tags
google-antigravity/claude-sonnet-4-5       text+image 195k     no    yes   default,configured
google/gemini-2.5-pro                      text+image 1024k    no    yes   fallback#1,configured
google/gemini-2.0-flash                    text+image 1024k    no    yes   fallback#2,configured
```

**Note**: The Auth column for `claude-sonnet-4-5` should show **yes** ✅

### 2. Test Main Agent (Claude Sonnet 4.5)

```bash
openclaw agent --agent main --message "你好！请告诉我你是什么模型，并简要介绍你的能力。请用中文回答。"
```

**Expected Result**: Model identifies itself as Claude, not Gemini

### 3. Test Fast Bot (Claude Sonnet 4.5)

```bash
openclaw agent --agent fast --message "你好！请确认你是Claude模型。"
```

### 4. Test Fallback Mechanism

To test if fallback works, temporarily disable Antigravity:
```bash
openclaw plugins disable google-antigravity-auth
openclaw gateway restart
openclaw agent --agent main --message "你好"  # Should use Gemini Pro

# Restore
openclaw plugins enable google-antigravity-auth
openclaw gateway restart
```

### 5. Check Agent Configuration

```bash
openclaw agents list
```

Expected output:
```
- main (default)
  Model: google-antigravity/claude-sonnet-4-5
- pro (Pro Bot)
  Model: google/gemini-2.5-pro
- fast (Claude Bot)
  Model: google-antigravity/claude-sonnet-4-5
```

---

## 📊 Cost Estimation (Using Your 300 Credits)

### Claude Sonnet 4.5 Pricing
- **Input**: $3 per million tokens
- **Output**: $15 per million tokens
- **Cache Read**: $0.30 per million tokens
- **Cache Write**: $3.75 per million tokens

### Actual Usage Estimation

Assuming average per conversation:
- Input: ~1,000 tokens
- Output: ~500 tokens

**Cost per Conversation**:
```
Cost = (1,000 × $3/1M) + (500 × $15/1M)
     = $0.003 + $0.0075
     = $0.0105 per conversation
```

**Number of Conversations with 300 Credits**:
```
Count = $300 ÷ $0.0105
      ≈ 28,571 conversations
```

### Comparison with Opus 4.5

If using Opus 4.5 ($5/$25):
- Cost per conversation: $0.0175
- With 300 Credits: 17,143 times
- **Save 40% using Sonnet 4.5!**

### Money Saving Tips

1. **Use Gemini for light tasks**: Simple Q&A with Pro Bot (free)
2. **Use Claude for complex tasks**: Use Main/Fast Bot when deep understanding is needed
3. **Monitor usage**: Check Credits usage in Google Cloud Console
4. **Set alerts**: Get notified when remaining Credits fall below a threshold

---

## 🔧 Troubleshooting Common Issues

### Issue 1: OAuth Authentication Failed

**Symptom**: Browser doesn't open or authentication times out

**Solution**:
```bash
# Check if port 51121 is occupied
lsof -i :51121

# If occupied, kill the process
kill -9 <PID>

# Retry authentication
openclaw models auth login --provider google-antigravity
```

### Issue 2: "No API key found for provider google-antigravity"

**Symptom**: Main Agent automatically falls back to Gemini

**Cause**: OAuth authentication not completed or token expired

**Solution**:
```bash
# Re-authenticate
openclaw models auth login --provider google-antigravity

# Or logout and re-authenticate
openclaw models auth logout --provider google-antigravity
openclaw models auth login --provider google-antigravity
```

### Issue 3: Claude Bot Not Responding

**Symptom**: Telegram Claude Bot doesn't reply

**Troubleshooting Steps**:
```bash
# 1. Check Gateway status
openclaw gateway status

# 2. View logs
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 3. Check Agent configuration
openclaw agents list

# 4. Test command line
openclaw agent --agent fast --message "测试"

# 5. Restart Gateway
openclaw gateway restart
```

### Issue 4: Google Account Permission Insufficient

**Symptom**: OAuth authorization page shows permission error

**Possible Causes**:
- Google account doesn't have Cloud Code Assist access permission
- Credits exhausted
- Account restricted

**Solution**:
1. Check Credits balance in Google Cloud Console
2. Confirm account has access to Code Assist service
3. Try using another Google account

### Issue 5: Model Response Error or Poor Quality

**Check if correct model is being used**:
```bash
openclaw agent --agent main --message "请告诉我你的模型名称和版本"
```

If it shows Gemini instead of Claude, it means:
- OAuth authentication not completed
- Or fallback mechanism has been triggered

---

## 📂 Important File Locations

| File Path | Purpose |
|---------|------|
| `~/.openclaw/openclaw.json` | Main configuration file |
| `~/.openclaw/openclaw.json.backup-before-claude-20260212` | Configuration backup |
| `~/.openclaw/.env` | Google Gemini API Key |
| `~/.openclaw/agents/main/agent/auth-profiles.json` | Main Agent authentication info |
| `~/.openclaw/agents/fast/agent/auth-profiles.json` | Fast Bot authentication info |
| `~/.openclaw/authenticate-claude.sh` | OAuth authentication script |
| `/tmp/openclaw/openclaw-2026-02-12.log` | Today's log |

---

## 🔄 How to Restore Original Configuration

If you need to return to Gemini-only configuration:

```bash
# 1. Restore backup
cp ~/.openclaw/openclaw.json.backup-before-claude-20260212 ~/.openclaw/openclaw.json

# 2. Restart Gateway
openclaw gateway restart

# 3. (Optional) Disable Antigravity plugin
openclaw plugins disable google-antigravity-auth
openclaw gateway restart
```

---

## 📈 Configuration Comparison

### Before Modification (Gemini Only)
| Item | Configuration |
|------|------|
| Default model | Gemini 2.0 Flash |
| Pro Bot | Gemini 2.5 Pro |
| Fast Bot | Gemini 2.0 Flash |
| Fallback | Gemini 2.5 Pro |
| Authentication | Google API Key |
| Cost | Google API free tier |

### After Modification (Claude + Gemini)
| Item | Configuration |
|------|------|
| Default model | **Claude Sonnet 4.5** |
| Pro Bot | Gemini 2.5 Pro |
| Fast Bot | **Claude Sonnet 4.5** |
| Fallback | Gemini 2.5 Pro → Flash |
| Authentication | OAuth + API Key |
| Cost | Google 300 Credits |

---

## 🎯 Final Configuration Details

### openclaw.json Core Configuration

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

## 📞 Getting More Help

- **OpenClaw Documentation**: https://docs.openclaw.ai
- **Troubleshooting**: https://docs.openclaw.ai/troubleshooting
- **Google Antigravity**: https://cloud.google.com/code-assist
- **Claude API Documentation**: https://docs.anthropic.com

---

**Configuration Completed**: 2026-02-12  
**Current Status**: ✅ Configuration Complete, ⏳ Awaiting OAuth Authentication  
**Next Step**: Run `bash ~/.openclaw/authenticate-claude.sh` to complete OAuth authentication

---

**Tip**: After completing OAuth authentication, please run the test commands again to verify that Claude Sonnet 4.5 is working properly!
