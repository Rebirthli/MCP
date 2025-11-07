# MinerU MCP Server

A Model Context Protocol (MCP) server for document parsing using MinerU service (HTTP transport).

## Features

- Parse PDF, PPT, Word, and image files to Markdown
- Support both local files and URLs
- HTTP transport for web-based integration
- Automatic file download from URLs

## Installation

### Quick Start with Docker (推荐)

```bash
# 1. 复制环境变量模板
cp .env.example .env

# 2. 编辑 .env 设置 MinerU 服务地址
# MINERU_URL=http://your-mineru-server:8080/parse

# 3. 启动服务
docker-compose up -d

# 4. 查看日志
docker-compose logs -f
```

### 从源码安装

```bash
# Install in development mode
cd MinerU_MCP_Server
pip install -e .
```
## Configuration

### 1. Set up environment variables

Create a `.env` file in the project root:

```bash
cp .env.example .env
# Edit .env and set your MinerU service URL
```

Example `.env`:
```bash
MINERU_URL=http://localhost:8080/parse
```

### 2. Start the server

```bash
# Run directly
mineru-mcp

# Or with Python
python -m mineru_mcp_server.server
```

The server will start on `http://0.0.0.0:18888`

### 3. Configure Claude Desktop (HTTP)

Add to your Claude Desktop configuration:

**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Linux:** `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "mineru-document-parser": {
      "url": "http://192.168.5.15:18080/mineru-mcp"
    }
  }
}
```

> **注意**: 如果Claude Desktop运行在同一台服务器上，可以使用 `http://localhost:18080/mineru-mcp`

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

## Architecture

```
Claude Desktop (HTTP client)
    ↓
MinerU MCP Server (FastMCP, HTTP transport)
    ↓
MinerU HTTP Service (Document parsing)
```

## Documentation
- **[.env.example](.env.example)** - 环境变量配置模板

## License

MIT

