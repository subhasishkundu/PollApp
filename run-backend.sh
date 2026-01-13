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

# Check if schema exists
echo "Checking database schema..."
if ! mysql -u root -padmin -e "USE pollapp; SELECT 1 FROM users LIMIT 1" 2>/dev/null; then
    echo "Warning: Database schema not found!"
    echo "Please run the migration script first:"
    echo "  ./scripts/migrate.sh"
    echo ""
    read -p "Do you want to run the migration now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/migrate.sh
    else
        echo "Exiting. Please run migrations before starting the server."
        exit 1
    fi
fi

# Run the server
echo "Starting server on http://localhost:8080"
echo "Logs will be displayed in this terminal. Press Ctrl+C to stop."
go run cmd/server/main.go
