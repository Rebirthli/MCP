# MinerU MCP Server

A Model Context Protocol (MCP) server for document parsing using MinerU service (HTTP transport).

## Features

- Parse PDF, PPT, Word, and image files to Markdown
- Support both local files and URLs
- HTTP transport for web-based integration
- Automatic file download from URLs

## Installation

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

The server will start on `http://0.0.0.0:8000`

### 3. Configure Claude Desktop (HTTP)

Add to your Claude Desktop configuration:

**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Linux:** `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "mineru": {
      "url": "http://localhost:8000/mcp"
    }
  }
}
```

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

## License

MIT

