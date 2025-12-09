#!/bin/bash

# Script to start both backend and ngrok

echo "🚀 Starting PARTIZO Backend and ngrok..."
echo ""

# Check if backend is already running
if lsof -ti:3000 > /dev/null; then
    echo "✅ Backend already running on port 3000"
else
    echo "📦 Starting backend server..."
    cd "$(dirname "$0")/backend"
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "📥 Installing dependencies..."
        npm install
    fi
    
    # Start backend in background
    node server.js > /tmp/partizo-backend.log 2>&1 &
    BACKEND_PID=$!
    echo "✅ Backend started (PID: $BACKEND_PID)"
    sleep 2
fi

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "❌ ngrok not found"
    echo "   Install with: brew install ngrok"
    echo "   Or download from: https://ngrok.com/download"
    exit 1
fi

# Check if ngrok is already running
if curl -s http://localhost:4040/api/tunnels > /dev/null 2>&1; then
    echo "✅ ngrok already running"
    echo ""
    echo "📋 Current ngrok URL:"
    curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; data = json.load(sys.stdin); [print(f\"  {t['public_url']}\") for t in data.get('tunnels', []) if 'https' in t['public_url']]" 2>/dev/null || echo "  (check http://localhost:4040)"
else
    echo "🌐 Starting ngrok tunnel..."
    echo ""
    echo "📋 After ngrok starts, copy the HTTPS URL and update:"
    echo "   lib/config/api_config.dart"
    echo "   - Set production = 'https://YOUR_NGROK_URL.ngrok.io/api'"
    echo "   - Set useProduction = true"
    echo ""
    echo "Press Ctrl+C to stop both backend and ngrok"
    echo ""
    
    ngrok http 3000
fi

