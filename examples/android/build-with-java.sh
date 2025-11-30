#!/bin/bash
# Helper script to build with a specific Java version
# Usage: ./build-with-java.sh /path/to/java/home

if [ -z "$1" ]; then
    echo "Usage: ./build-with-java.sh /path/to/java/home"
    echo "Example: ./build-with-java.sh /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
    exit 1
fi

export JAVA_HOME="$1"
echo "Using Java from: $JAVA_HOME"
$JAVA_HOME/bin/java -version
./gradlew build
