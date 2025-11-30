#!/bin/bash

# Test script for version validation
# This script tests various version formats to ensure validation works correctly

echo "Testing version validation..."
echo ""

# Save original version
ORIGINAL_VERSION=$(grep "VERSION_NAME=" gradle.properties | cut -d'=' -f2)
echo "Original version: $ORIGINAL_VERSION"
echo ""

# Test cases
declare -a VALID_VERSIONS=(
    "1.0.0"
    "0.1.0"
    "2.3.4"
    "1.0.0-alpha"
    "1.0.0-beta.1"
    "1.0.0-rc.2"
    "1.0.0+20130313144700"
    "1.0.0-beta.1+exp.sha.5114f85"
)

declare -a INVALID_VERSIONS=(
    "1.0"
    "v1.0.0"
    "1.0.0.0"
    "1.0.0-SNAPSHOT"
    ""
    "1"
)

echo "=== Testing Valid Versions ==="
for version in "${VALID_VERSIONS[@]}"; do
    echo -n "Testing $version ... "
    sed -i.bak "s/VERSION_NAME=.*/VERSION_NAME=$version/" gradle.properties
    if ./gradlew validateVersion -q > /dev/null 2>&1; then
        echo "✓ PASS"
    else
        echo "✗ FAIL (should be valid)"
    fi
done

echo ""
echo "=== Testing Invalid Versions ==="
for version in "${INVALID_VERSIONS[@]}"; do
    echo -n "Testing '$version' ... "
    sed -i.bak "s/VERSION_NAME=.*/VERSION_NAME=$version/" gradle.properties
    if ./gradlew validateVersion -q > /dev/null 2>&1; then
        echo "✗ FAIL (should be invalid)"
    else
        echo "✓ PASS (correctly rejected)"
    fi
done

# Restore original version
echo ""
echo "Restoring original version: $ORIGINAL_VERSION"
sed -i.bak "s/VERSION_NAME=.*/VERSION_NAME=$ORIGINAL_VERSION/" gradle.properties
rm gradle.properties.bak

echo ""
echo "Version validation tests complete!"
