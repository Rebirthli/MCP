FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 升级pip并配置国内镜像源（提高速度和稳定性）
RUN pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制依赖文件
COPY pyproject.toml ./

# 复制源代码
COPY src/ ./src/

# 安装依赖（使用国内镜像源）
RUN pip install --no-cache-dir -e . -i https://pypi.tuna.tsinghua.edu.cn/simple

# 暴露端口
EXPOSE 18888

# 设置环境变量（默认值，可通过 docker run 覆盖）
ENV MINERU_URL=http://mineru-service:8080/parse

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:18888/health')" || exit 1

# 启动服务
CMD ["mineru-mcp"]
