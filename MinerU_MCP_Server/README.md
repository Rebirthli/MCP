# MinerU MCP Server

A Model Context Protocol (MCP) server for document parsing using MinerU service.

## 🚀 Deployment
MinerU MCP Server 现仅支持 **HTTP 传输**，有两种典型使用方式：

### 🖥️ 本地 HTTP启动
- 在本机克隆仓库并运行 `python -m mineru_mcp_server.server`
- MCP Inspector / Claude Desktop / Continue / Cline / Zed 等客户端通过 `http://localhost:18888/mcp` 连接
- 仍然可以在 `file_source` 中填写本地文件路径，服务会直接读取再将内容上传到 MinerU
- 所有请求都会通过 `MINERU_URL` 转发给远程 MinerU 服务处理

### 🌐 远程 HTTP部署
- 通过 Docker Compose、systemd、Supervisor 等方式部署在服务器
- 可配合 Nginx/Traefik 暴露到公网或添加鉴权
- 多个客户端可共享同一实例

> **提示**：远程 HTTP 部署时，服务器只能访问它所能下载的 URL；若需要解析本地文件，请在本机启动 HTTP 服务（或确保服务器能访问该文件所在的网络存储）。
## Features

- Parse PDF, PPT, Word, and image files to Markdown
- 支持 HTTP/HTTPS URL（远程部署）以及本地文件路径（本地 HTTP 模式）
- 单一 HTTP 传输模式，可本地或远程部署
- Automatic file download from URLs

## Installation

### Option 1: Local HTTP (run from source)

```bash
# 1. Clone or download the repository
cd MinerU_MCP_Server

# 2. Install in development mode
pip install -e .

# 3. Create .env file
cp .env.example .env

# 4. Edit .env and set:
#    MINERU_URL=http://your-mineru-server:23800/file_parse
#    TRANSPORT=http

# 5. Start the HTTP server
python -m mineru_mcp_server.server
```

### Option 2: Server Mode (HTTP) - For Remote Deployment

```bash
# 1. 复制环境变量模板
cp .env.example .env

# 2. 编辑 .env 设置 MinerU 服务地址和传输模式
#    MINERU_URL=http://your-mineru-server:23800/file_parse
#    TRANSPORT=http

# 3. 启动 Docker 服务
docker-compose up -d

# 4. 查看日志
docker-compose logs -f
```

## Configuration

### Environment Variables

Create a `.env` file with:

```bash
# MinerU HTTP service URL (required)
MINERU_URL=http://your-mineru-server:endpoint/file_parse

# Transport mode (HTTP only)
TRANSPORT=http

# Temporary directory (optional)
TMPDIR=/tmp
```

### Configure Claude Desktop / Inspector (HTTP)

将 MinerU MCP Server 以 HTTP 方式运行后，在 Claude Desktop、MCP Inspector、Continue 等客户端里添加如下配置：

**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Linux:** `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "mineru-document-parser": {
      "url": "http://localhost:18888/mcp"
    }
  }
}
```

> **说明**：如果你把服务部署在远程服务器或放在 Nginx 后面，只需把 `url` 改成对应地址（例如 `http://your-server:18080/mineru-mcp`）。
## MCP Tool

### `parse_document`

Parse a document to Markdown format.

**Parameters:**
- `file_source` (str): Local file path or HTTP/HTTPS URL

**Returns:**
- Markdown content as string

**Examples:**

```python
# Parse local PDF
parse_document(file_source="/path/to/document.pdf")

# Parse from URL
parse_document(file_source="https://example.com/document.pdf")

# Parse image
parse_document(file_source="/path/to/image.png")
```

## Supported Formats

- **PDF** - .pdf
- **PowerPoint** - .ppt, .pptx
- **Word** - .doc, .docx
- **Images** - .jpg, .jpeg, .png, .bmp

## Requirements

- Python 3.10+
- MinerU HTTP service running and accessible
- FastMCP library

## Troubleshooting

### "MINERU_URL is not set"
Create a `.env` file with `MINERU_URL=http://your-service-url`

### "Connection refused"
Ensure your MinerU HTTP service is running and accessible at the configured URL.

### "Download failed"
Check that the URL is accessible and the file exists.

## Development

```bash
# Install dependencies
pip install -e ".[dev]"

# Run server
python -m mineru_mcp_server.server

# Format code
ruff format .
```

## TODO

- 发布项目至 PyPI，解锁 `uvx mineru-mcp-server` 等免安装运行方式。

## Architecture

### 本地 HTTP 部署

```
MCP Client (Inspector / Claude Desktop / Continue)
    ↓ HTTP request (http://localhost:18888/mcp)
MinerU MCP Server (runs locally in HTTP mode)
    ↓ HTTP request (MINERU_URL)
Remote MinerU Service
```

**Key Points:**
- 使用者临时启动 MCP 服务即可；无需暴露到网络
- 可以借助本地代理或回环地址调试
- 依赖远程 MinerU 服务完成解析

### 远程 HTTP 部署

```
MCP Client (any HTTP-capable client)
    ↓ HTTP request (https://mcp.example.com/mineru-mcp)
MinerU MCP Server (Docker/systemd/Nginx)
    ↓ HTTP request (MINERU_URL)
Remote MinerU Service
```

**Key Points:**
- 可以部署在一台服务器上供多人共用
- 仅支持 URL 输入，不直接访问客户端本地文件
- 建议搭配 Nginx/Traefik 进行鉴权和 TLS 加密
## License

MIT

