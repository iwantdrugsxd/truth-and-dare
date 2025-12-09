#!/bin/bash

# Quick script to start the backend server

cd "$(dirname "$0")/backend"

echo "🚀 Starting PARTIZO Backend Server..."
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚙️  Creating .env file..."
    cat > .env << EOF
PORT=3000
DATABASE_URL=postgresql://localhost:5432/partizo
NODE_ENV=development
JWT_SECRET=your-secret-key-change-in-production
EOF
    echo "✅ Created .env file - please update DATABASE_URL with your credentials"
fi

# Check if database exists
echo "🗄️  Checking database..."
if ! psql -lqt | cut -d \| -f 1 | grep -qw partizo; then
    echo "📊 Creating database..."
    createdb partizo 2>/dev/null || echo "⚠️  Could not create database - may already exist or need manual setup"
    
    echo "📋 Setting up schema..."
    psql -d partizo -f database/schema.sql 2>/dev/null || echo "⚠️  Could not run schema - check database connection"
fi

echo ""
echo "🎯 Starting server on http://localhost:3000"
echo "   Press Ctrl+C to stop"
echo ""

npm start


