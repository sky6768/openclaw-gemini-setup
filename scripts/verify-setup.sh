#!/bin/bash
# OpenClaw Gemini 配置验证脚本
# OpenClaw Gemini Configuration Verification Script

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_header "OpenClaw Gemini 配置验证 / Configuration Verification"

ERRORS=0

# 检查 OpenClaw 安装
export PATH="$HOME/.npm-global/bin:$PATH"
if command -v openclaw &> /dev/null; then
    VERSION=$(openclaw --version 2>&1 | head -1)
    print_check 0 "OpenClaw 已安装: $VERSION / OpenClaw installed: $VERSION"
else
    print_check 1 "OpenClaw 未安装 / OpenClaw not installed"
    ((ERRORS++))
fi

# 检查 .env 文件
if [ -f ~/.openclaw/.env ]; then
    print_check 0 ".env 文件存在 / .env file exists"
    
    source ~/.openclaw/.env
    if [ -n "$GEMINI_API_KEY" ]; then
        print_check 0 "GEMINI_API_KEY 已设置 / GEMINI_API_KEY is set"
    else
        print_check 1 "GEMINI_API_KEY 未设置 / GEMINI_API_KEY not set"
        ((ERRORS++))
    fi
else
    print_check 1 ".env 文件不存在 / .env file missing"
    ((ERRORS++))
fi

# 检查 auth-profiles.json
if [ -f ~/.openclaw/agents/main/agent/auth-profiles.json ]; then
    print_check 0 "auth-profiles.json 存在 / auth-profiles.json exists"
    
    if grep -q "apiKey" ~/.openclaw/agents/main/agent/auth-profiles.json; then
        print_check 0 "API Key 已配置在认证文件中 / API Key configured in auth file"
    else
        print_check 1 "认证文件中未找到 API Key / API Key not found in auth file"
        ((ERRORS++))
    fi
else
    print_check 1 "auth-profiles.json 不存在 / auth-profiles.json missing"
    ((ERRORS++))
fi

# 检查 openclaw.json
if [ -f ~/.openclaw/openclaw.json ]; then
    print_check 0 "openclaw.json 存在 / openclaw.json exists"
    
    if grep -q "gemini" ~/.openclaw/openclaw.json; then
        print_check 0 "Gemini 模型已配置 / Gemini model configured"
    else
        print_check 1 "未找到 Gemini 模型配置 / Gemini model config not found"
        ((ERRORS++))
    fi
else
    print_check 1 "openclaw.json 不存在 / openclaw.json missing"
    ((ERRORS++))
fi

# 检查 Gateway 状态
if openclaw gateway status &> /dev/null; then
    print_check 0 "Gateway 服务运行中 / Gateway service running"
else
    print_check 1 "Gateway 服务未运行 / Gateway service not running"
    ((ERRORS++))
fi

# 测试 API 连接
echo ""
echo -e "${BLUE}测试 API 连接... / Testing API connection...${NC}"

TEST_OUTPUT=$(openclaw agent --agent main --message "Reply with OK" 2>&1)
if echo "$TEST_OUTPUT" | grep -qi "ok\|working"; then
    print_check 0 "API 连接测试成功 / API connection test passed"
else
    print_check 1 "API 连接测试失败 / API connection test failed"
    echo "输出 / Output:"
    echo "$TEST_OUTPUT" | tail -3
    ((ERRORS++))
fi

# 总结
print_header "验证结果 / Verification Results"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过！配置正确。${NC}"
    echo -e "${GREEN}✓ All checks passed! Configuration is correct.${NC}"
    exit 0
else
    echo -e "${RED}✗ 发现 $ERRORS 个问题${NC}"
    echo -e "${RED}✗ Found $ERRORS issue(s)${NC}"
    echo ""
    echo "请运行以下命令重新配置："
    echo "Please run the following to reconfigure:"
    echo "  ./scripts/setup-gemini.sh"
    exit 1
fi
