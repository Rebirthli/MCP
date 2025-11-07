#!/bin/bash

# MinerU MCP Server 快速部署脚本

set -e  # 遇到错误立即退出

echo "=================================="
echo "MinerU MCP Server - 快速部署"
echo "=================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未检测到 Docker${NC}"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}错误: 未检测到 docker-compose${NC}"
    echo "请先安装 docker-compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker 环境检测通过${NC}"
echo ""

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠ 未找到 .env 文件，从模板创建...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}请编辑 .env 文件设置 MINERU_URL${NC}"
    echo ""
    read -p "按 Enter 继续，或 Ctrl+C 退出编辑 .env..."
fi

# 读取环境变量
source .env

if [ -z "$MINERU_URL" ]; then
    echo -e "${RED}错误: MINERU_URL 未设置${NC}"
    echo "请在 .env 文件中设置 MINERU_URL"
    exit 1
fi

echo -e "${GREEN}✓ 配置文件检查通过${NC}"
echo "  MinerU URL: $MINERU_URL"
echo ""

# 停止旧容器（如果存在）
if docker ps -a | grep -q mineru-mcp-server; then
    echo "停止旧容器..."
    docker-compose down
fi

# 构建镜像
echo ""
echo "构建 Docker 镜像..."
docker-compose build

# 启动服务
echo ""
echo "启动服务..."
docker-compose up -d

# 等待服务启动
echo ""
echo "等待服务启动..."
sleep 5

# 检查服务状态
if docker ps | grep -q mineru-mcp-server; then
    echo ""
    echo -e "${GREEN}=================================="
    echo "✓ 部署成功！"
    echo "==================================${NC}"
    echo ""
    echo "服务信息："
    echo "  - 容器名称: mineru-mcp-server"
    echo "  - 访问地址: http://localhost:8000"
    echo "  - 健康检查: http://localhost:8000/health"
    echo ""
    echo "常用命令："
    echo "  查看日志: docker-compose logs -f"
    echo "  停止服务: docker-compose down"
    echo "  重启服务: docker-compose restart"
    echo "  查看状态: docker ps | grep mineru-mcp"
    echo ""
    echo "配置 Claude Desktop："
    echo "  在 claude_desktop_config.json 中添加："
    echo '  {'
    echo '    "mcpServers": {'
    echo '      "mineru": {'
    echo '        "url": "http://localhost:8000/mcp"'
    echo '      }'
    echo '    }'
    echo '  }'
    echo ""
else
    echo -e "${RED}=================================="
    echo "✗ 部署失败"
    echo "==================================${NC}"
    echo ""
    echo "请查看日志排查问题:"
    echo "  docker-compose logs"
    exit 1
fi
