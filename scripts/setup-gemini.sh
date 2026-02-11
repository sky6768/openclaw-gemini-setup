#!/bin/bash
# OpenClaw Gemini API 自动配置脚本
# OpenClaw Gemini API Automated Setup Script
#
# 作者 / Author: sky6768
# 日期 / Date: 2026-02-11

set -e

# 颜色定义 / Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息 / Function: Print colored messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# 检查 OpenClaw 是否已安装 / Check if OpenClaw is installed
check_openclaw() {
    print_header "检查 OpenClaw 安装 / Checking OpenClaw Installation"
    
    export PATH="$HOME/.npm-global/bin:$PATH"
    
    if ! command -v openclaw &> /dev/null; then
        print_error "OpenClaw 未安装或不在 PATH 中"
        print_error "OpenClaw is not installed or not in PATH"
        print_info "请先安装 OpenClaw: https://openclaw.ai"
        print_info "Please install OpenClaw first: https://openclaw.ai"
        exit 1
    fi
    
    OPENCLAW_VERSION=$(openclaw --version 2>&1 | head -1)
    print_success "OpenClaw 已安装: $OPENCLAW_VERSION"
    print_success "OpenClaw is installed: $OPENCLAW_VERSION"
}

# 获取 API Key / Get API Key
get_api_key() {
    print_header "配置 Gemini API Key / Configure Gemini API Key"
    
    echo "请访问以下链接获取您的 Gemini API Key："
    echo "Please visit the following link to get your Gemini API Key:"
    echo ""
    echo "  👉 https://makersuite.google.com/app/apikey"
    echo ""
    
    read -p "请输入您的 Gemini API Key / Enter your Gemini API Key: " API_KEY
    
    if [ -z "$API_KEY" ]; then
        print_error "API Key 不能为空 / API Key cannot be empty"
        exit 1
    fi
    
    # 基本验证 API Key 格式 / Basic API key format validation
    if [[ ! "$API_KEY" =~ ^AIza ]]; then
        print_warning "警告: API Key 格式可能不正确（通常以 'AIza' 开头）"
        print_warning "Warning: API Key format may be incorrect (usually starts with 'AIza')"
        read -p "是否继续？/ Continue? (y/N): " CONTINUE
        if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "API Key 已接收 / API Key received"
}

# 创建 .env 文件 / Create .env file
create_env_file() {
    print_header "创建环境变量文件 / Creating Environment Variable File"
    
    mkdir -p ~/.openclaw
    
    # 备份现有文件 / Backup existing file
    if [ -f ~/.openclaw/.env ]; then
        BACKUP_FILE=~/.openclaw/.env.backup-$(date +%Y%m%d-%H%M%S)
        cp ~/.openclaw/.env "$BACKUP_FILE"
        print_info "已备份现有 .env 文件到: $BACKUP_FILE"
        print_info "Backed up existing .env to: $BACKUP_FILE"
    fi
    
    # 创建新的 .env 文件 / Create new .env file
    cat > ~/.openclaw/.env << EOF
# OpenClaw 环境变量配置
# 创建时间: $(date)

# Gemini API Configuration
GEMINI_API_KEY=$API_KEY
GOOGLE_API_KEY=$API_KEY
EOF
    
    chmod 600 ~/.openclaw/.env
    print_success "环境变量文件已创建: ~/.openclaw/.env"
    print_success "Environment variable file created: ~/.openclaw/.env"
}

# 创建 auth-profiles.json / Create auth-profiles.json
create_auth_profiles() {
    print_header "创建 Agent 认证文件 / Creating Agent Authentication File"
    
    mkdir -p ~/.openclaw/agents/main/agent
    
    # 备份现有文件 / Backup existing file
    if [ -f ~/.openclaw/agents/main/agent/auth-profiles.json ]; then
        BACKUP_FILE=~/.openclaw/agents/main/agent/auth-profiles.json.backup-$(date +%Y%m%d-%H%M%S)
        cp ~/.openclaw/agents/main/agent/auth-profiles.json "$BACKUP_FILE"
        print_info "已备份现有认证文件到: $BACKUP_FILE"
        print_info "Backed up existing auth file to: $BACKUP_FILE"
    fi
    
    # 创建新的认证文件 / Create new auth file
    cat > ~/.openclaw/agents/main/agent/auth-profiles.json << EOF
{
  "profiles": {
    "google": {
      "provider": "google",
      "auth": "api-key",
      "apiKey": "$API_KEY"
    }
  }
}
EOF
    
    chmod 600 ~/.openclaw/agents/main/agent/auth-profiles.json
    print_success "认证文件已创建: ~/.openclaw/agents/main/agent/auth-profiles.json"
    print_success "Authentication file created: ~/.openclaw/agents/main/agent/auth-profiles.json"
}

# 更新 openclaw.json / Update openclaw.json
update_openclaw_config() {
    print_header "更新 OpenClaw 配置 / Updating OpenClaw Configuration"
    
    CONFIG_FILE=~/.openclaw/openclaw.json
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_warning "配置文件不存在，将创建新文件"
        print_warning "Config file doesn't exist, creating new one"
        
        cat > "$CONFIG_FILE" << 'EOF'
{
  "agents": {
    "defaults": {
      "workspace": "$HOME/.openclaw/workspace",
      "model": {
        "primary": "google/gemini-2.0-flash"
      }
    }
  },
  "models": {
    "mode": "merge"
  }
}
EOF
        print_success "配置文件已创建 / Configuration file created"
    else
        # 检查是否已配置 Gemini / Check if Gemini is already configured
        if grep -q "google/gemini" "$CONFIG_FILE"; then
            print_success "配置文件已包含 Gemini 模型配置"
            print_success "Configuration file already contains Gemini model"
        else
            print_info "请手动编辑配置文件添加 Gemini 模型"
            print_info "Please manually edit the config file to add Gemini model"
            print_info "文件位置 / File location: $CONFIG_FILE"
        fi
    fi
}

# 重启 Gateway 服务 / Restart Gateway service
restart_gateway() {
    print_header "重启 Gateway 服务 / Restarting Gateway Service"
    
    export PATH="$HOME/.npm-global/bin:$PATH"
    
    if openclaw gateway status &> /dev/null; then
        openclaw gateway restart
        sleep 2
        print_success "Gateway 服务已重启 / Gateway service restarted"
    else
        print_warning "Gateway 服务未运行，尝试启动..."
        print_warning "Gateway service not running, trying to start..."
        openclaw gateway start || print_warning "无法启动 Gateway / Cannot start Gateway"
    fi
}

# 验证配置 / Verify configuration
verify_setup() {
    print_header "验证配置 / Verifying Configuration"
    
    export PATH="$HOME/.npm-global/bin:$PATH"
    source ~/.openclaw/.env
    
    # 检查环境变量 / Check environment variables
    if [ -n "$GEMINI_API_KEY" ]; then
        print_success "环境变量已设置 / Environment variables set"
    else
        print_error "环境变量未正确设置 / Environment variables not set correctly"
    fi
    
    # 检查文件 / Check files
    if [ -f ~/.openclaw/.env ]; then
        print_success ".env 文件存在 / .env file exists"
    else
        print_error ".env 文件不存在 / .env file missing"
    fi
    
    if [ -f ~/.openclaw/agents/main/agent/auth-profiles.json ]; then
        print_success "认证文件存在 / Auth file exists"
    else
        print_error "认证文件不存在 / Auth file missing"
    fi
    
    # 测试 API 连接 / Test API connection
    print_info "测试 Gemini API 连接... / Testing Gemini API connection..."
    
    TEST_RESPONSE=$(openclaw agent --agent main --message "Hello! Please reply with 'OK' if you're working." 2>&1 | tail -5)
    
    if echo "$TEST_RESPONSE" | grep -qi "ok\|working\|yes"; then
        print_success "API 连接测试成功！/ API connection test successful!"
    else
        print_warning "API 连接测试未能确认，请手动验证"
        print_warning "API connection test inconclusive, please verify manually"
        echo "响应 / Response: $TEST_RESPONSE"
    fi
}

# 显示完成信息 / Show completion message
show_completion() {
    print_header "配置完成！/ Configuration Complete!"
    
    echo -e "${GREEN}✓${NC} Gemini API 已成功配置到 OpenClaw"
    echo -e "${GREEN}✓${NC} Gemini API has been successfully configured with OpenClaw"
    echo ""
    echo "配置文件位置 / Configuration files:"
    echo "  • ~/.openclaw/.env"
    echo "  • ~/.openclaw/agents/main/agent/auth-profiles.json"
    echo "  • ~/.openclaw/openclaw.json"
    echo ""
    echo "使用方法 / Usage:"
    echo "  • 命令行 / Command line: openclaw agent --agent main --message '你的消息'"
    echo "  • Web UI: http://127.0.0.1:18789/"
    echo ""
    echo "更新 API Key / Update API Key:"
    echo "  • 运行脚本 / Run script: ./scripts/update-api-key.sh"
    echo ""
    echo -e "${BLUE}文档 / Documentation:${NC}"
    echo "  • README: https://github.com/sky6768/openclaw-gemini-setup"
    echo "  • 故障排除 / Troubleshooting: docs/troubleshooting.md"
    echo ""
}

# 主函数 / Main function
main() {
    print_header "OpenClaw Gemini API 配置向导 / OpenClaw Gemini API Setup Wizard"
    
    check_openclaw
    get_api_key
    create_env_file
    create_auth_profiles
    update_openclaw_config
    restart_gateway
    verify_setup
    show_completion
}

# 运行主函数 / Run main function
main
