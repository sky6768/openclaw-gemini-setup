#!/bin/bash
# OpenClaw 启动脚本
# 自动加载环境变量和设置 PATH

# 设置颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  OpenClaw with Gemini API${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 添加 OpenClaw 到 PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# 加载环境变量
if [ -f ~/.openclaw/.env ]; then
    source ~/.openclaw/.env
    echo -e "${GREEN}✓${NC} 环境变量已加载"
else
    echo -e "${YELLOW}⚠${NC} 警告: ~/.openclaw/.env 文件未找到"
fi

# 验证 API Key
if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${YELLOW}⚠${NC} 警告: GEMINI_API_KEY 未设置"
else
    echo -e "${GREEN}✓${NC} GEMINI_API_KEY 已设置"
fi

# 验证 OpenClaw 命令
if command -v openclaw &> /dev/null; then
    echo -e "${GREEN}✓${NC} OpenClaw 命令可用"
    OPENCLAW_VERSION=$(openclaw --version 2>&1 | head -1)
    echo -e "  版本: ${OPENCLAW_VERSION}"
else
    echo -e "${YELLOW}⚠${NC} 错误: OpenClaw 命令未找到"
    echo "  请确保 OpenClaw 已正确安装"
    exit 1
fi

echo ""
echo -e "${BLUE}当前配置:${NC}"
echo -e "  默认模型: ${GREEN}google/gemini-2.0-flash${NC}"
echo -e "  配置文件: ~/.openclaw/openclaw.json"
echo -e "  API Key 文件: ~/.openclaw/.env"
echo ""

# 显示可用命令
echo -e "${BLUE}可用命令:${NC}"
echo "  openclaw agent --agent main --message \"你的消息\"  # 发送消息"
echo "  openclaw agents list                             # 查看 Agent 列表"
echo "  openclaw models list                             # 查看可用模型"
echo "  openclaw doctor                                  # 检查配置健康状态"
echo ""

# 如果提供了参数，执行 OpenClaw 命令
if [ $# -gt 0 ]; then
    echo -e "${BLUE}执行命令:${NC} openclaw $@"
    echo ""
    openclaw "$@"
else
    echo -e "${BLUE}提示:${NC} 您可以直接使用 openclaw 命令，环境变量已经加载。"
    echo "      例如: openclaw agent --agent main --message \"你好\""
fi
