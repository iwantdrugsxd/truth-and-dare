#!/bin/bash

# Script to start ngrok tunnel for backend

echo "🔐 Starting ngrok HTTPS tunnel..."
echo ""

# Check if backend is running
if ! lsof -ti:3000 > /dev/null; then
    echo "⚠️  Backend not running on port 3000"
    echo "   Starting backend first..."
    cd "$(dirname "$0")/backend"
    node server.js > /tmp/partizo-backend.log 2>&1 &
    sleep 2
    echo "✅ Backend started"
fi

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "❌ ngrok not found"
    echo "   Install with: brew install ngrok"
    echo "   Or download from: https://ngrok.com/download"
    exit 1
fi

echo "🌐 Creating HTTPS tunnel to localhost:3000..."
echo ""
echo "📋 Copy the 'Forwarding' URL (https://xxx.ngrok.io)"
echo "   Then update lib/config/api_config.dart:"
echo "   - Set production = 'https://xxx.ngrok.io/api'"
echo "   - Set useProduction = true"
echo ""
echo "Press Ctrl+C to stop ngrok"
echo ""

ngrok http 3000

