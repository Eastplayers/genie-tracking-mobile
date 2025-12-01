#!/bin/bash
# Setup script to install git hooks for security

echo "🔧 Setting up git hooks for security..."

# Method 1: Configure git to use .githooks directory (recommended)
if git config core.hooksPath .githooks; then
    echo "✅ Git hooks configured to use .githooks directory"
    echo "   All hooks in .githooks/ will now run automatically"
else
    echo "⚠️  Failed to configure git hooks path"
    echo "   Falling back to manual copy method..."
    
    # Method 2: Copy hooks to .git/hooks (fallback)
    if [ -d ".git/hooks" ]; then
        cp .githooks/pre-commit .git/hooks/pre-commit
        chmod +x .git/hooks/pre-commit
        echo "✅ Pre-commit hook copied to .git/hooks/"
    else
        echo "❌ Error: .git/hooks directory not found"
        echo "   Are you in the root of a git repository?"
        exit 1
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "The pre-commit hook will now:"
echo "  • Prevent committing .env files"
echo "  • Scan for API keys and passwords"
echo "  • Check for large files"
echo ""
echo "To bypass the hook (use with caution):"
echo "  git commit --no-verify"
