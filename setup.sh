#!/bin/bash

# Setup script for Modern Software Development Practices Documentation
# This script sets up the MkDocs environment for local development

set -e

echo "🚀 Setting up Modern Software Development Practices Documentation"
echo "================================================================="

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed. Please install Python 3.7+ and try again."
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"

# Install MkDocs if not already installed
if ! python3 -c "import mkdocs" &> /dev/null; then
    echo "📦 Installing MkDocs..."
    python3 -m pip install mkdocs
else
    echo "✅ MkDocs already installed"
fi

# Install optional Material theme (recommended)
read -p "📦 Do you want to install the Material theme for enhanced UI? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Installing Material theme and extensions..."
    python3 -m pip install mkdocs-material pymdown-extensions
    
    # Update mkdocs.yml to use Material theme
    echo "📝 Updating configuration to use Material theme..."
    sed -i.bak 's/name: readthedocs/name: material/' mkdocs.yml
    
    # Add Material theme configuration
    cat > temp_theme_config.yml << 'EOF'
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - search.highlight
    - content.code.copy
  palette:
    scheme: default
    primary: red
    accent: red
EOF
    
    # Replace theme section in mkdocs.yml
    python3 -c "
import yaml
import sys

# Read current config
with open('mkdocs.yml', 'r') as f:
    config = yaml.safe_load(f)

# Update theme configuration for Material
config['theme'] = {
    'name': 'material',
    'features': [
        'navigation.tabs',
        'navigation.sections', 
        'navigation.expand',
        'search.highlight',
        'content.code.copy'
    ],
    'palette': {
        'scheme': 'default',
        'primary': 'red',
        'accent': 'red'
    }
}

# Update markdown extensions for Material
config['markdown_extensions'] = [
    'admonition',
    'codehilite',
    {'toc': {'permalink': True}},
    'pymdownx.superfences',
    'pymdownx.tabbed',
    'pymdownx.details'
]

# Write updated config
with open('mkdocs.yml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False, sort_keys=False)
    
print('✅ Material theme configuration updated')
"
    rm -f temp_theme_config.yml
    echo "✅ Material theme installed and configured"
else
    echo "📝 Using ReadTheDocs theme (default)"
fi

# Test the build
echo "🔧 Testing MkDocs build..."
if python3 -m mkdocs build --clean; then
    echo "✅ Documentation builds successfully"
else
    echo "❌ Build failed. Please check the configuration."
    exit 1
fi

# Provide usage instructions
echo ""
echo "🎉 Setup complete! Here's how to use the documentation:"
echo "=================================================="
echo ""
echo "📖 Serve documentation locally:"
echo "   python3 -m mkdocs serve"
echo "   Then open: http://localhost:8000"
echo ""
echo "🏗️  Build static site:"
echo "   python3 -m mkdocs build"
echo ""
echo "🐳 Using with Podman/Docker:"
echo "   podman build -f Containerfile.docs -t docs-dev ."
echo "   podman run -p 8000:8000 docs-dev"
echo ""
echo "📚 Documentation structure:"
echo "   docs/               - Source markdown files"
echo "   mkdocs.yml         - Configuration file"
echo "   site/              - Generated static site"
echo ""
echo "✨ Happy documenting!"

