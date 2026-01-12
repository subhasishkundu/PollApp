#!/bin/bash

# Run backend with logs saved to file

echo "Starting Poll App Backend with logging..."
cd backend

# Check if go.mod exists
if [ ! -f "go.mod" ]; then
    echo "Error: go.mod not found. Make sure you're in the correct directory."
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Download dependencies
echo "Downloading Go dependencies..."
go mod download

# Generate ent code
echo "Generating ent code..."
go generate ./ent

# Run the server with logs
LOG_FILE="logs/server-$(date +%Y%m%d-%H%M%S).log"
echo "Starting server on http://localhost:8080"
echo "Logs will be saved to: backend/$LOG_FILE"
echo "Press Ctrl+C to stop the server"
go run cmd/server/main.go 2>&1 | tee "$LOG_FILE"
