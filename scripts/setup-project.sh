#!/bin/bash

# Poll App Project Setup Script
# This script sets up the project by checking/installing git, cloning/pulling the repository
# Usage: ./setup-project.sh [target_directory]
# 
# Requirements: Run with sudo privileges for git installation

set -e  # Exit on error

# Configuration
REPO_URL="https://github.com/subhasishkundu/PollApp.git"
REPO_NAME="PollApp"
TARGET_DIR="${1:-$HOME}"

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

echo "=========================================="
echo "Poll App Project Setup"
echo "=========================================="
echo ""

# Step 1: Check and Install Git
print_info "Step 1: Checking for Git installation..."

if command -v git &> /dev/null; then
    print_success "Git is already installed"
    git --version
else
    print_info "Git is not installed. Installing via yum..."
    
    # Check if running as root for installation
    if [ "$EUID" -ne 0 ]; then
        print_error "Git installation requires root privileges"
        print_info "Please run with sudo: sudo $0"
        exit 1
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
    
    # Update package list and install git
    $PACKAGE_MANAGER update -y
    $PACKAGE_MANAGER install -y git
    
    if [ $? -eq 0 ]; then
        print_success "Git installed successfully"
        git --version
    else
        print_error "Failed to install Git"
        exit 1
    fi
fi

echo ""

# Step 2: Clone or Pull Repository
print_info "Step 2: Setting up repository..."

PROJECT_DIR="$TARGET_DIR/$REPO_NAME"

if [ -d "$PROJECT_DIR" ]; then
    print_info "Directory '$PROJECT_DIR' already exists"
    
    # Check if it's a git repository
    if [ -d "$PROJECT_DIR/.git" ]; then
        print_info "Existing git repository found. Pulling latest changes..."
        cd "$PROJECT_DIR"
        
        # Check if there are uncommitted changes
        if ! git diff-index --quiet HEAD --; then
            print_info "Warning: Uncommitted changes detected. Stashing them..."
            git stash
        fi
        
        # Pull latest changes
        git pull origin main || git pull origin master
        
        if [ $? -eq 0 ]; then
            print_success "Repository updated successfully"
        else
            print_error "Failed to pull latest changes"
            exit 1
        fi
    else
        print_error "Directory exists but is not a git repository"
        print_info "Please remove the directory or choose a different location"
        exit 1
    fi
else
    print_info "Cloning repository to '$PROJECT_DIR'..."
    cd "$TARGET_DIR"
    git clone "$REPO_URL" "$REPO_NAME"
    
    if [ $? -eq 0 ]; then
        print_success "Repository cloned successfully"
        cd "$PROJECT_DIR"
    else
        print_error "Failed to clone repository"
        exit 1
    fi
fi

echo ""

# Step 3: Verify Setup
print_info "Step 3: Verifying setup..."

if [ -d "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR/.git" ]; then
    print_success "Project setup completed successfully"
    echo ""
    echo "=========================================="
    print_success "Setup Complete!"
    echo "=========================================="
    echo ""
    echo "Project Location: $PROJECT_DIR"
    echo ""
    echo "Next steps:"
    echo "  1. Change to project directory: cd $PROJECT_DIR"
    echo "  2. Configure database: sudo ./scripts/setup-mysql.sh"
    echo "  3. Install Go: sudo ./scripts/install-golang.sh"
    echo "  4. Configure app: ./scripts/configure-app.sh"
    echo ""
else
    print_error "Setup verification failed"
    exit 1
fi

# Change to project directory
cd "$PROJECT_DIR"
print_info "Changed to project directory: $(pwd)"
