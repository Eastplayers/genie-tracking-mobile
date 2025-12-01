#!/bin/bash

# Trigger JitPack Build Script
# Usage: ./trigger-jitpack.sh [version]
# If no version is provided, reads from gradle.properties

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub repository details
GITHUB_USER="Eastplayers"
GITHUB_REPO="genie-tracking-mobile"

# Function to extract version from gradle.properties
get_version_from_gradle() {
    if [ -f "gradle.properties" ]; then
        VERSION=$(grep "^VERSION_NAME=" gradle.properties | cut -d'=' -f2)
        if [ -z "$VERSION" ]; then
            echo -e "${RED}Error: VERSION_NAME not found in gradle.properties${NC}"
            exit 1
        fi
        echo "$VERSION"
    else
        echo -e "${RED}Error: gradle.properties not found${NC}"
        exit 1
    fi
}

# Get version from parameter or gradle.properties
if [ -z "$1" ]; then
    echo -e "${BLUE}No version specified, reading from gradle.properties...${NC}"
    VERSION=$(get_version_from_gradle)
    echo -e "${BLUE}Using version: ${GREEN}$VERSION${NC}"
else
    VERSION="$1"
    echo -e "${BLUE}Using specified version: ${GREEN}$VERSION${NC}"
fi

# Add 'v' prefix if not present
if [[ ! $VERSION == v* ]]; then
    VERSION="v$VERSION"
fi

# JitPack API endpoint
JITPACK_URL="https://jitpack.io/api/builds/com.github.${GITHUB_USER}/${GITHUB_REPO}/${VERSION}"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Triggering JitPack Build${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${BLUE}Repository:${NC} ${GITHUB_USER}/${GITHUB_REPO}"
echo -e "${BLUE}Version:${NC} ${VERSION}"
echo -e "${BLUE}JitPack URL:${NC} ${JITPACK_URL}"
echo ""

# Trigger the build
echo -e "${BLUE}Sending request to JitPack...${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" "$JITPACK_URL")

# Extract HTTP status code (last line)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

# Extract response body (all but last line)
BODY=$(echo "$RESPONSE" | sed '$d')

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Response${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${BLUE}HTTP Status:${NC} $HTTP_CODE"
echo -e "${BLUE}Response Body:${NC}"
echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
echo ""

# Check if successful
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✓ Build triggered successfully!${NC}"
    echo ""
    echo -e "${BLUE}View build status at:${NC}"
    echo -e "  ${GREEN}https://jitpack.io/#${GITHUB_USER}/${GITHUB_REPO}/${VERSION}${NC}"
    echo ""
    echo -e "${BLUE}Once built, use in your project:${NC}"
    echo -e "  ${YELLOW}implementation 'com.github.${GITHUB_USER}:${GITHUB_REPO}:${VERSION}'${NC}"
    exit 0
else
    echo -e "${RED}✗ Build trigger failed${NC}"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo -e "  1. Tag ${VERSION} doesn't exist in GitHub"
    echo -e "  2. Repository is private (JitPack requires public repos or authentication)"
    echo -e "  3. Build configuration error in jitpack.yml"
    echo ""
    echo -e "${BLUE}Create and push the tag:${NC}"
    echo -e "  ${YELLOW}git tag ${VERSION}${NC}"
    echo -e "  ${YELLOW}git push origin ${VERSION}${NC}"
    exit 1
fi
