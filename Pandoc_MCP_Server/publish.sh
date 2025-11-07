#!/bin/bash

# Pandoc MCP Server - Quick Publish Script
# This script automates the PyPI publishing process

set -e  # Exit on error

echo "🚀 Pandoc MCP Server - Publishing to PyPI"
echo "=========================================="
echo

# Check if build tools are installed
echo "📦 Checking build tools..."
if ! command -v python &> /dev/null; then
    echo "❌ Python not found. Please install Python 3.10+"
    exit 1
fi

# Install/upgrade build tools
echo "📦 Installing build tools..."
pip install --upgrade build twine

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist/ build/ src/*.egg-info

# Build the package
echo "🔨 Building package..."
python -m build

# Check the build
echo "✅ Build complete. Files created:"
ls -lh dist/

echo
echo "📋 Next steps:"
echo "1. Upload to TestPyPI (recommended first):"
echo "   python -m twine upload --repository testpypi dist/*"
echo
echo "2. Or upload to real PyPI:"
echo "   python -m twine upload dist/*"
echo
echo "3. Test installation:"
echo "   pip install --index-url https://test.pypi.org/simple/ pandoc-mcp-server"
echo "   # or from real PyPI:"
echo "   pip install pandoc-mcp-server"
echo

read -p "📤 Upload to TestPyPI now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📤 Uploading to TestPyPI..."
    python -m twine upload --repository testpypi dist/*
    echo "✅ Uploaded to TestPyPI!"
    echo "🔗 Check: https://test.pypi.org/project/pandoc-mcp-server/"
    echo
    read -p "📤 Upload to real PyPI now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📤 Uploading to PyPI..."
        python -m twine upload dist/*
        echo "✅ Published to PyPI!"
        echo "🔗 Check: https://pypi.org/project/pandoc-mcp-server/"
    fi
fi

echo
echo "✨ Done!"
