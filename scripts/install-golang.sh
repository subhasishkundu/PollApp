#!/bin/bash

# Go (Golang) Installation Script for Poll App
# This script installs Go using yum/dnf
# Usage: ./install-golang.sh
# 
# Requirements: Run as root or with sudo privileges

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

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root or with sudo"
    exit 1
fi

echo "=========================================="
echo "Go (Golang) Installation for Poll App"
echo "=========================================="
echo ""

# Check if Go is already installed
if command -v go &> /dev/null; then
    print_success "Go is already installed"
    go version
    exit 0
fi

# Detect package manager
if command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
    print_info "Detected dnf package manager (Fedora)"
elif command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
    print_info "Detected yum package manager (RHEL/CentOS)"
else
    print_error "Neither yum nor dnf found. This script is for RHEL/CentOS/Fedora only."
    exit 1
fi

# Step 1: Install EPEL (for RHEL/CentOS)
if [ "$PACKAGE_MANAGER" = "yum" ]; then
    print_info "Step 1: Installing EPEL repository (if needed)..."
    
    if yum list installed epel-release &>/dev/null; then
        print_success "EPEL repository already installed"
    else
        $PACKAGE_MANAGER install -y epel-release
        if [ $? -eq 0 ]; then
            print_success "EPEL repository installed successfully"
        else
            print_error "Failed to install EPEL repository"
            exit 1
        fi
    fi
    echo ""
fi

# Step 2: Install Go
print_info "Step 2: Installing Go..."

$PACKAGE_MANAGER update -y
$PACKAGE_MANAGER install -y golang

if [ $? -eq 0 ]; then
    print_success "Go installed successfully"
else
    print_error "Failed to install Go"
    exit 1
fi

echo ""

# Step 3: Verify Installation
print_info "Step 3: Verifying installation..."

if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    print_success "Go installation verified"
    echo ""
    echo "Installed version:"
    echo "  $GO_VERSION"
    echo ""
    
    # Check Go version meets requirement (1.23+)
    GO_MAJOR=$(echo "$GO_VERSION" | grep -oP 'go\d+' | grep -oP '\d+' | head -1)
    if [ -n "$GO_MAJOR" ] && [ "$GO_MAJOR" -ge 1 ]; then
        print_success "Go version check passed"
    fi
    
    echo ""
    echo "=========================================="
    print_success "Go installation completed successfully!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Set up GOPATH and GOROOT if needed"
    echo "  2. Navigate to backend directory: cd backend"
    echo "  3. Install dependencies: go mod download"
    echo "  4. Generate ent code: go generate ./ent"
    echo ""
else
    print_error "Go installation verification failed"
    exit 1
fi
