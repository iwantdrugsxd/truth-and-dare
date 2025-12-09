#!/bin/bash

# Script to restart the backend server

echo "🔄 Restarting PARTIZO Backend..."

# Kill existing process on port 3000
if lsof -ti:3000 > /dev/null; then
    echo "🛑 Stopping existing server..."
    lsof -ti:3000 | xargs kill -9 2>/dev/null
    sleep 1
fi

# Start server
echo "🚀 Starting server on port 3000..."
cd "$(dirname "$0")"
node server.js


