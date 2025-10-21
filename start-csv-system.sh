#!/bin/bash

# Solana Verifiable Build - CSV Processing System Startup Script

echo "================================================"
echo "Solana Verifiable Build - CSV Processing System"
echo "================================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo ""

# Check if dependencies are installed
if [ ! -d "backend/node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    cd backend && npm install && cd ..
    echo ""
fi

if [ ! -d "frontend/node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    cd frontend && npm install && cd ..
    echo ""
fi

echo "🚀 Starting servers..."
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start backend
echo "🔧 Starting MCP Backend (Port 3001)..."
cd backend && npm start &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 2

# Start frontend
echo "🌐 Starting Frontend (Port 3000)..."
cd frontend && npm start &
FRONTEND_PID=$!
cd ..

echo ""
echo "================================================"
echo "✅ Servers are running!"
echo "================================================"
echo ""
echo "📝 Frontend: http://localhost:3000"
echo "🔌 Backend:  http://localhost:3001"
echo "🏥 Health:   http://localhost:3001/mcp/health"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for both processes
wait
