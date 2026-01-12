#!/bin/bash

echo "Starting Poll App Backend..."
cd backend

# Check if go.mod exists
if [ ! -f "go.mod" ]; then
    echo "Error: go.mod not found. Make sure you're in the correct directory."
    exit 1
fi

# Download dependencies
echo "Downloading Go dependencies..."
go mod download

# Generate ent code
echo "Generating ent code..."
go generate ./ent

# Run the server
echo "Starting server on http://localhost:8080"
echo "Logs will be displayed in this terminal. Press Ctrl+C to stop."
go run cmd/server/main.go
