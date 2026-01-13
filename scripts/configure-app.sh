#!/bin/bash

# Poll App Configuration Script
# This script sets up the frontend and backend of the Poll App
# Usage: ./configure-app.sh
# 
# Requirements: 
#   - Go 1.23+ installed (run ./scripts/install-golang.sh first)
#   - MySQL configured (run ./scripts/setup-mysql.sh first)
#   - Node.js 16+ and npm installed

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Poll App Configuration"
echo "=========================================="
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Step 1: Verify Prerequisites
print_info "Step 1: Verifying prerequisites..."

# Check Go
if ! command -v go &> /dev/null; then
    print_error "Go is not installed"
    print_info "Please run: sudo ./scripts/install-golang.sh"
    exit 1
else
    GO_VERSION=$(go version)
    print_success "Go is installed: $GO_VERSION"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    print_info "Please install Node.js 16+ from https://nodejs.org/"
    exit 1
else
    NODE_VERSION=$(node --version)
    print_success "Node.js is installed: $NODE_VERSION"
fi

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed"
    print_info "Please install npm (usually comes with Node.js)"
    exit 1
else
    NPM_VERSION=$(npm --version)
    print_success "npm is installed: v$NPM_VERSION"
fi

# Check MySQL
if ! command -v mysql &> /dev/null; then
    print_error "MySQL is not installed"
    print_info "Please run: sudo ./scripts/setup-mysql.sh"
    exit 1
else
    print_success "MySQL is installed"
fi

echo ""

# Step 2: Backend Setup
print_info "Step 2: Setting up backend..."

cd "$PROJECT_ROOT/backend"

# Install Go dependencies
print_info "Installing Go dependencies..."
go mod download

if [ $? -eq 0 ]; then
    print_success "Go dependencies installed successfully"
else
    print_error "Failed to install Go dependencies"
    exit 1
fi

# Generate ent code
print_info "Generating ent code..."
go generate ./ent

if [ $? -eq 0 ]; then
    print_success "Ent code generated successfully"
else
    print_error "Failed to generate ent code"
    exit 1
fi

echo ""

# Step 3: Frontend Setup
print_info "Step 3: Setting up frontend..."

cd "$PROJECT_ROOT/frontend"

# Install npm dependencies
print_info "Installing npm dependencies..."
npm install

if [ $? -eq 0 ]; then
    print_success "npm dependencies installed successfully"
else
    print_error "Failed to install npm dependencies"
    exit 1
fi

echo ""

# Step 4: Verify Setup
print_info "Step 4: Verifying setup..."

# Check backend
if [ -f "$PROJECT_ROOT/backend/go.mod" ] && [ -d "$PROJECT_ROOT/backend/ent" ]; then
    print_success "Backend setup verified"
else
    print_error "Backend setup verification failed"
    exit 1
fi

# Check frontend
if [ -f "$PROJECT_ROOT/frontend/package.json" ] && [ -d "$PROJECT_ROOT/frontend/node_modules" ]; then
    print_success "Frontend setup verified"
else
    print_error "Frontend setup verification failed"
    exit 1
fi

echo ""
echo "=========================================="
print_success "App Configuration Completed!"
echo "=========================================="
echo ""
echo "Setup Summary:"
echo "  ✓ Go dependencies installed"
echo "  ✓ Ent code generated"
echo "  ✓ Frontend dependencies installed"
echo ""
echo "Next steps:"
echo "  1. Ensure MySQL is running and database is set up"
echo "  2. Start backend: cd backend && go run cmd/server/main.go"
echo "     Or use: ./run-backend.sh"
echo "  3. Start frontend: cd frontend && npm start"
echo "     Or use: ./run-frontend.sh"
echo ""
echo "The backend will run on http://localhost:8080"
echo "The frontend will run on http://localhost:3000"
echo ""
