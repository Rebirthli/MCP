@echo off
REM Pandoc MCP Server - Quick Publish Script for Windows
REM This script automates the PyPI publishing process

echo.
echo 🚀 Pandoc MCP Server - Publishing to PyPI
echo ==========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.10+
    exit /b 1
)

REM Install/upgrade build tools
echo 📦 Installing build tools...
pip install --upgrade build twine

REM Clean previous builds
echo 🧹 Cleaning previous builds...
if exist dist rmdir /s /q dist
if exist build rmdir /s /q build
for /d %%i in (src\*.egg-info) do rmdir /s /q "%%i"

REM Build the package
echo 🔨 Building package...
python -m build

REM Check the build
echo ✅ Build complete. Files created:
dir dist

echo.
echo 📋 Next steps:
echo 1. Upload to TestPyPI (recommended first):
echo    python -m twine upload --repository testpypi dist/*
echo.
echo 2. Or upload to real PyPI:
echo    python -m twine upload dist/*
echo.
echo 3. Test installation:
echo    pip install --index-url https://test.pypi.org/simple/ pandoc-mcp-server
echo    # or from real PyPI:
echo    pip install pandoc-mcp-server
echo.

set /p upload_test="📤 Upload to TestPyPI now? (y/N): "
if /i "%upload_test%"=="y" (
    echo 📤 Uploading to TestPyPI...
    python -m twine upload --repository testpypi dist/*
    echo ✅ Uploaded to TestPyPI!
    echo 🔗 Check: https://test.pypi.org/project/pandoc-mcp-server/
    echo.
    set /p upload_real="📤 Upload to real PyPI now? (y/N): "
    if /i "%upload_real%"=="y" (
        echo 📤 Uploading to PyPI...
        python -m twine upload dist/*
        echo ✅ Published to PyPI!
        echo 🔗 Check: https://pypi.org/project/pandoc-mcp-server/
    )
)

echo.
echo ✨ Done!
pause
