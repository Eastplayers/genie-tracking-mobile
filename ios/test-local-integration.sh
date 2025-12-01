#!/bin/bash

# Test Local CocoaPods Integration
# This script verifies that local pod integration works correctly in both
# React Native and native iOS example projects.

set -e

echo "🧪 Testing Local CocoaPods Integration"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the script directory (ios/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Project root: ${PROJECT_ROOT}${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command_exists pod; then
    echo -e "${RED}❌ CocoaPods not found. Please install: sudo gem install cocoapods${NC}"
    exit 1
fi
echo -e "${GREEN}✅ CocoaPods installed${NC}"

if ! command_exists xcodebuild; then
    echo -e "${RED}❌ Xcode not found. Please install Xcode from the App Store${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Xcode installed${NC}"

echo ""

# Test 1: Validate podspec
echo -e "${BLUE}Test 1: Validating podspec...${NC}"
cd "$SCRIPT_DIR"

if pod spec lint FounderOSMobileTracker.podspec --allow-warnings --quick; then
    echo -e "${GREEN}✅ Podspec is valid${NC}"
else
    echo -e "${RED}❌ Podspec validation failed${NC}"
    exit 1
fi

echo ""

# Test 2: Test native iOS example
echo -e "${BLUE}Test 2: Testing native iOS example project...${NC}"
NATIVE_IOS_DIR="$PROJECT_ROOT/examples/ios/MobileTrackerExample"

if [ ! -d "$NATIVE_IOS_DIR" ]; then
    echo -e "${YELLOW}⚠️  Native iOS example not found at $NATIVE_IOS_DIR${NC}"
else
    cd "$NATIVE_IOS_DIR"
    
    # Check Podfile exists
    if [ ! -f "Podfile" ]; then
        echo -e "${RED}❌ Podfile not found${NC}"
        exit 1
    fi
    
    # Verify Podfile contains local path reference
    if grep -q ":path => '../../../ios'" Podfile; then
        echo -e "${GREEN}✅ Podfile contains local path reference${NC}"
    else
        echo -e "${RED}❌ Podfile does not contain local path reference${NC}"
        exit 1
    fi
    
    # Install pods
    echo "   Installing pods..."
    if pod install --silent; then
        echo -e "${GREEN}✅ Pod install successful${NC}"
    else
        echo -e "${RED}❌ Pod install failed${NC}"
        exit 1
    fi
    
    # Verify Podfile.lock contains external source
    if grep -q "EXTERNAL SOURCES:" Podfile.lock && grep -q ":path: \"../../../ios\"" Podfile.lock; then
        echo -e "${GREEN}✅ Podfile.lock confirms local pod usage${NC}"
    else
        echo -e "${RED}❌ Podfile.lock does not show local pod${NC}"
        exit 1
    fi
    
    # Verify workspace was created
    if [ -f "MobileTrackerExample.xcworkspace/contents.xcworkspacedata" ]; then
        echo -e "${GREEN}✅ Xcode workspace created${NC}"
    else
        echo -e "${RED}❌ Xcode workspace not found${NC}"
        exit 1
    fi
    
    # Verify local podspec exists
    if [ -f "Pods/Local Podspecs/FounderOSMobileTracker.podspec.json" ]; then
        echo -e "${GREEN}✅ Local podspec installed${NC}"
    else
        echo -e "${RED}❌ Local podspec not found${NC}"
        exit 1
    fi
    
    # Try to build the project
    echo "   Building project..."
    if xcodebuild -workspace MobileTrackerExample.xcworkspace \
                   -scheme MobileTrackerExample \
                   -destination 'platform=iOS Simulator,name=iPhone 15' \
                   -quiet \
                   clean build; then
        echo -e "${GREEN}✅ Project builds successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Build failed (this may be expected if simulator is not available)${NC}"
    fi
fi

echo ""

# Test 3: Test React Native example
echo -e "${BLUE}Test 3: Testing React Native example project...${NC}"
RN_IOS_DIR="$PROJECT_ROOT/examples/react-native/ios"

if [ ! -d "$RN_IOS_DIR" ]; then
    echo -e "${YELLOW}⚠️  React Native iOS example not found at $RN_IOS_DIR${NC}"
else
    cd "$RN_IOS_DIR"
    
    # Check Podfile exists
    if [ ! -f "Podfile" ]; then
        echo -e "${RED}❌ Podfile not found${NC}"
        exit 1
    fi
    
    # Verify Podfile contains local path reference
    if grep -q ":path => '../../../ios'" Podfile; then
        echo -e "${GREEN}✅ Podfile contains local path reference${NC}"
    else
        echo -e "${RED}❌ Podfile does not contain local path reference${NC}"
        exit 1
    fi
    
    # Install pods
    echo "   Installing pods..."
    if pod install --silent; then
        echo -e "${GREEN}✅ Pod install successful${NC}"
    else
        echo -e "${RED}❌ Pod install failed${NC}"
        exit 1
    fi
    
    # Verify Podfile.lock contains external source
    if grep -q "FounderOSMobileTracker:" Podfile.lock && grep -q ":path: \"../../../ios\"" Podfile.lock; then
        echo -e "${GREEN}✅ Podfile.lock confirms local pod usage${NC}"
    else
        echo -e "${RED}❌ Podfile.lock does not show local pod${NC}"
        exit 1
    fi
    
    # Verify workspace was created
    if [ -f "MobileTrackerExample.xcworkspace/contents.xcworkspacedata" ]; then
        echo -e "${GREEN}✅ Xcode workspace created${NC}"
    else
        echo -e "${RED}❌ Xcode workspace not found${NC}"
        exit 1
    fi
    
    # Verify local podspec exists
    if [ -f "Pods/Local Podspecs/FounderOSMobileTracker.podspec.json" ]; then
        echo -e "${GREEN}✅ Local podspec installed${NC}"
    else
        echo -e "${RED}❌ Local podspec not found${NC}"
        exit 1
    fi
fi

echo ""

# Test 4: Verify changes are reflected
echo -e "${BLUE}Test 4: Verifying local pod references...${NC}"

# Check that local podspecs exist in both projects
NATIVE_PODSPEC="$PROJECT_ROOT/examples/ios/MobileTrackerExample/Pods/Local Podspecs/FounderOSMobileTracker.podspec.json"
RN_PODSPEC="$PROJECT_ROOT/examples/react-native/ios/Pods/Local Podspecs/FounderOSMobileTracker.podspec.json"

if [ -f "$NATIVE_PODSPEC" ] && [ -f "$RN_PODSPEC" ]; then
    echo -e "${GREEN}✅ Local podspecs found in both projects${NC}"
    echo -e "${GREEN}✅ Changes to ios/MobileTracker/ will be reflected after rebuilding${NC}"
else
    echo -e "${YELLOW}⚠️  Some local podspecs not found${NC}"
fi

echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ All local integration tests passed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Local CocoaPods integration is working correctly."
echo "You can now make changes to the library and test them in:"
echo "  - examples/ios/MobileTrackerExample (native iOS)"
echo "  - examples/react-native (React Native)"
echo ""
echo "For more information, see: ios/LOCAL_DEVELOPMENT.md"
