#!/bin/bash

# Email Writer Backend - Run Script
# This script loads environment variables from .env and runs the JAR file

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables from .env file
if [ -f .env ]; then
    echo "📦 Loading environment variables from .env..."
    export $(grep -v '^#' .env | xargs)
else
    echo "⚠️  No .env file found. Please create one from .env.example"
    echo "   Run: cp .env.example .env"
    exit 1
fi

# Check if JAR exists
JAR_FILE="target/email-writer-0.0.1-SNAPSHOT.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "📦 JAR file not found. Building..."
    ./mvnw clean package -DskipTests
fi

# Check for required environment variables
if [ -z "$GEMINI_URL" ] || [ -z "$GEMINI_KEY" ]; then
    echo "⚠️  Warning: GEMINI_URL or GEMINI_KEY not set in .env file"
    echo "   The application may not work correctly without these values."
fi

echo "🚀 Starting Email Writer Backend..."
echo "   Server URL: http://localhost:8080"
echo "   Press Ctrl+C to stop"
echo ""

# Run the JAR with environment variables
java -jar "$JAR_FILE"
