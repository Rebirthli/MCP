"""
MinerU MCP Server - Document Parsing Service

A FastMCP server implementation that provides document parsing capabilities
using MinerU HTTP service.

Design: HTTP transport for easy web-based integration
"""

import os
import logging
import dotenv
import aiohttp
from pathlib import Path
from urllib.parse import urlparse
from fastmcp import FastMCP
from starlette.requests import Request
from starlette.responses import JSONResponse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Initialize FastMCP application
app = FastMCP(name="mineru-document-parser")

# Load environment variables
dotenv.load_dotenv()
MINERU_URL = os.getenv("MINERU_URL")
if not MINERU_URL:
    raise RuntimeError("Environment variable MINERU_URL is not set")


# Health check endpoint
@app.custom_route("/health", methods=["GET"])
async def health_check(request: Request) -> JSONResponse:
    """Health check endpoint for monitoring."""
    return JSONResponse({"status": "healthy", "service": "mineru-mcp-server"})


async def download_file_if_url(file_source: str) -> str:
    """
    Download file from URL to temporary file, or return local path.

    Args:
        file_source: File path or HTTP/HTTPS URL

    Returns:
        Local file path

    Raises:
        ValueError: If download fails
        FileNotFoundError: If local file doesn't exist
    """
    parsed = urlparse(file_source)
    if parsed.scheme in ("http", "https"):
        # Download to temporary file
        async with aiohttp.ClientSession() as session:
            async with session.get(file_source) as resp:
                if resp.status != 200:
                    raise ValueError(f"Download failed: HTTP {resp.status}")
                content = await resp.read()
                # Infer filename
                filename = Path(parsed.path).name or "downloaded_file"
                temp_dir = Path(os.getenv("TMPDIR", os.getenv("TEMP", "/tmp")))
                temp_file = temp_dir / filename
                temp_file.write_bytes(content)
                logging.info(f"Downloaded file to: {temp_file}")
                return str(temp_file)
    else:
        # Local path - check existence
        if not os.path.exists(file_source):
            raise FileNotFoundError(f"File not found: {file_source}")
        return file_source


@app.tool()
async def parse_document(file_source: str) -> str:
    """
    Parse document to Markdown format. Supports PDF, PPT, Word, and image formats.

    Args:
        file_source: File path or HTTP/HTTPS URL

    Returns:
        Converted Markdown content
    """
    try:
        # Handle URL or local path
        local_path = await download_file_if_url(file_source)
        logging.info(f"Parsing document: {local_path}")

        # Send file to MinerU service
        async with aiohttp.ClientSession() as session:
            with open(local_path, "rb") as f:
                data = aiohttp.FormData()
                data.add_field(
                    'file',
                    f,
                    filename=Path(local_path).name,
                    content_type='application/octet-stream'
                )
                data.add_field('parse_method', 'auto')
                data.add_field('is_json_md_dump', 'false')
                data.add_field('output_dir', '/output/results')
                data.add_field('return_layout', 'false')
                data.add_field('return_info', 'false')
                data.add_field('return_content_list', 'false')
                data.add_field('return_images', 'false')

                async with session.post(MINERU_URL, data=data) as response:
                    if response.status != 200:
                        error_text = await response.text()
                        error_msg = f"MinerU request failed: HTTP {response.status}\n{error_text}"
                        logging.error(error_msg)
                        return error_msg

                    try:
                        result = await response.json()
                        md_content = result.get("md_content")
                        if md_content is None:
                            error_msg = f"Response missing 'md_content' field.\nRaw response: {result}"
                            logging.error(error_msg)
                            return error_msg

                        logging.info(f"Successfully parsed: {Path(local_path).name}")
                        return md_content

                    except Exception as e:
                        text = await response.text()
                        error_msg = f"Failed to parse JSON response: {e}\nRaw response: {text}"
                        logging.error(error_msg)
                        return error_msg

    except Exception as e:
        error_msg = f"Error processing file: {str(e)}"
        logging.error(error_msg)
        return error_msg


def main():
    """
    Start the MinerU MCP server.

    Currently only HTTP transport is supported. The server can be launched
    locally (for personal use) or remotely, and clients connect via HTTP.
    """
    transport = os.getenv("TRANSPORT", "http").lower()

    if transport != "http":
        raise RuntimeError(
            "Only HTTP transport is supported. Please remove TRANSPORT or set TRANSPORT=http."
        )

    logging.info("Starting MinerU MCP Server (v0.1.0)...")
    logging.info(f"MinerU service URL: {MINERU_URL}")
    logging.info("Transport mode: http")
    logging.info("Internal endpoint: http://0.0.0.0:18888/mcp")
    logging.info("External URL (via nginx): http://<your-server-ip>:18080/mineru-mcp")
    logging.info("Health check: http://<your-server-ip>:18080/health")
    app.run(transport="http", host="0.0.0.0", port=18888, path="/mcp")


if __name__ == '__main__':
    main()
