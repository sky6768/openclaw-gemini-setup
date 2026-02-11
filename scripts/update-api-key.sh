#!/bin/bash
# OpenClaw Gemini API Key 更新脚本
# OpenClaw Gemini API Key Update Script

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_header "更新 Gemini API Key / Update Gemini API Key"

# 获取新的 API Key
echo "请输入新的 Gemini API Key:"
echo "Please enter your new Gemini API Key:"
read -p "> " NEW_API_KEY

if [ -z "$NEW_API_KEY" ]; then
    print_error "API Key 不能为空 / API Key cannot be empty"
    exit 1
fi

# 备份现有配置
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

print_info "备份现有配置... / Backing up existing configuration..."

if [ -f ~/.openclaw/.env ]; then
    cp ~/.openclaw/.env ~/.openclaw/.env.backup-$TIMESTAMP
    print_success "已备份 .env"
fi

if [ -f ~/.openclaw/agents/main/agent/auth-profiles.json ]; then
    cp ~/.openclaw/agents/main/agent/auth-profiles.json \
       ~/.openclaw/agents/main/agent/auth-profiles.json.backup-$TIMESTAMP
    print_success "已备份 auth-profiles.json"
fi

# 更新 .env 文件
print_info "更新环境变量文件... / Updating environment variable file..."

sed -i "s/^GEMINI_API_KEY=.*/GEMINI_API_KEY=$NEW_API_KEY/" ~/.openclaw/.env
sed -i "s/^GOOGLE_API_KEY=.*/GOOGLE_API_KEY=$NEW_API_KEY/" ~/.openclaw/.env

print_success ".env 文件已更新 / .env file updated"

# 更新 auth-profiles.json
print_info "更新认证文件... / Updating authentication file..."

cat > ~/.openclaw/agents/main/agent/auth-profiles.json << EOF
{
  "profiles": {
    "google": {
      "provider": "google",
      "auth": "api-key",
      "apiKey": "$NEW_API_KEY"
    }
  }
}
EOF

chmod 600 ~/.openclaw/agents/main/agent/auth-profiles.json
print_success "认证文件已更新 / Authentication file updated"

# 重启 Gateway
print_info "重启 Gateway 服务... / Restarting Gateway service..."

export PATH="$HOME/.npm-global/bin:$PATH"
openclaw gateway restart
sleep 2

print_success "Gateway 已重启 / Gateway restarted"

# 验证
print_info "验证新配置... / Verifying new configuration..."

source ~/.openclaw/.env
openclaw agent --agent main --message "Test" > /dev/null 2>&1 && \
    print_success "配置验证成功！/ Configuration verified!" || \
    print_warning "无法验证配置，请手动测试 / Cannot verify, please test manually"

print_header "完成！/ Complete!"
echo "API Key 已更新并已重启服务"
echo "API Key has been updated and service restarted"
echo ""
echo "备份文件位置 / Backup files:"
echo "  • ~/.openclaw/.env.backup-$TIMESTAMP"
echo "  • ~/.openclaw/agents/main/agent/auth-profiles.json.backup-$TIMESTAMP"
