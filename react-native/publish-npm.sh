#!/bin/bash

# Publish React Native package to npm
# Usage: ./publish-npm.sh [version]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Publishing React Native Package to npm${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if logged in to npm
if ! npm whoami &> /dev/null; then
    echo -e "${RED}Error: Not logged in to npm${NC}"
    echo -e "${YELLOW}Run: npm login${NC}"
    exit 1
fi

NPM_USER=$(npm whoami)
echo -e "${GREEN}✓ Logged in as: ${NPM_USER}${NC}"
echo ""

# Get current version from package.json
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo -e "${BLUE}Current version: ${CURRENT_VERSION}${NC}"

# If version parameter provided, update package.json
if [ ! -z "$1" ]; then
    NEW_VERSION="$1"
    echo -e "${YELLOW}Updating version to: ${NEW_VERSION}${NC}"
    npm version "$NEW_VERSION" --no-git-tag-version
    CURRENT_VERSION="$NEW_VERSION"
fi

echo ""
echo -e "${YELLOW}Pre-publish checklist:${NC}"
echo -e "  ${BLUE}1.${NC} Building TypeScript..."

# Build TypeScript
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo -e "  ${GREEN}✓ Build successful${NC}"

# Check if lib directory exists and has files
if [ ! -d "lib" ] || [ -z "$(ls -A lib)" ]; then
    echo -e "${RED}✗ lib directory is empty or doesn't exist${NC}"
    exit 1
fi

echo -e "  ${GREEN}✓ lib directory contains compiled files${NC}"

# Run tests
echo -e "  ${BLUE}2.${NC} Running tests..."
npm test

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi

echo -e "  ${GREEN}✓ Tests passed${NC}"

# Check package contents
echo ""
echo -e "${BLUE}Package contents (what will be published):${NC}"
npm pack --dry-run

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Ready to publish version ${CURRENT_VERSION}${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Confirm publication
read -p "Do you want to publish to npm? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Publication cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Publishing to npm...${NC}"

# Publish to npm
npm publish --access public

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Successfully published!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Package:${NC} founder-os-tracker-react-native@${CURRENT_VERSION}"
    echo -e "${BLUE}View at:${NC} https://www.npmjs.com/package/founder-os-tracker-react-native"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Create git tag: ${GREEN}git tag v${CURRENT_VERSION}${NC}"
    echo -e "  2. Push tag: ${GREEN}git push origin v${CURRENT_VERSION}${NC}"
    echo -e "  3. Test installation: ${GREEN}npm install founder-os-tracker-react-native@${CURRENT_VERSION}${NC}"
else
    echo ""
    echo -e "${RED}✗ Publication failed${NC}"
    exit 1
fi
