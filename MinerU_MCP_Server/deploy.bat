@echo off
REM MinerU MCP Server 快速部署脚本 (Windows)

echo ==================================
echo MinerU MCP Server - 快速部署
echo ==================================
echo.

REM 检查 Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Docker
    echo 请先安装 Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 docker-compose
    echo Docker Desktop 应该已包含 docker-compose
    pause
    exit /b 1
)

echo [OK] Docker 环境检测通过
echo.

REM 检查 .env 文件
if not exist ".env" (
    echo [警告] 未找到 .env 文件，从模板创建...
    copy .env.example .env
    echo 请编辑 .env 文件设置 MINERU_URL
    echo.
    pause
)

REM 停止旧容器
docker ps -a | findstr mineru-mcp-server >nul 2>&1
if not errorlevel 1 (
    echo 停止旧容器...
    docker-compose down
)

REM 构建镜像
echo.
echo 构建 Docker 镜像...
docker-compose build
if errorlevel 1 (
    echo [错误] 构建失败
    pause
    exit /b 1
)

REM 启动服务
echo.
echo 启动服务...
docker-compose up -d
if errorlevel 1 (
    echo [错误] 启动失败
    pause
    exit /b 1
)

REM 等待服务启动
echo.
echo 等待服务启动...
timeout /t 5 /nobreak >nul

REM 检查服务状态
docker ps | findstr mineru-mcp-server >nul 2>&1
if not errorlevel 1 (
    echo.
    echo ==================================
    echo [成功] 部署成功！
    echo ==================================
    echo.
    echo 服务信息：
    echo   - 容器名称: mineru-mcp-server
    echo   - 访问地址: http://localhost:8000
    echo   - 健康检查: http://localhost:8000/health
    echo.
    echo 常用命令：
    echo   查看日志: docker-compose logs -f
    echo   停止服务: docker-compose down
    echo   重启服务: docker-compose restart
    echo   查看状态: docker ps ^| findstr mineru-mcp
    echo.
    echo 配置 Claude Desktop：
    echo   在 %%APPDATA%%\Claude\claude_desktop_config.json 中添加：
    echo   {
    echo     "mcpServers": {
    echo       "mineru": {
    echo         "url": "http://localhost:8000/mcp"
    echo       }
    echo     }
    echo   }
    echo.
) else (
    echo.
    echo ==================================
    echo [失败] 部署失败
    echo ==================================
    echo.
    echo 请查看日志排查问题:
    echo   docker-compose logs
    pause
    exit /b 1
)

pause
