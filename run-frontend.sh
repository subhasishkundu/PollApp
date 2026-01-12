#!/bin/bash

echo "Starting Poll App Frontend..."
cd frontend

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found. Make sure you're in the correct directory."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install
fi

# Start the React development server
echo "Starting React app on http://localhost:3000"
npm start
