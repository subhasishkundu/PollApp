#!/bin/bash

# MySQL Installation and Setup Script for Poll App
# This script installs MySQL, configures root user, and creates the database schema
# Usage: ./setup-mysql.sh
# 
# Requirements: Run as root or with sudo privileges

set -e  # Exit on error

# Configuration
MYSQL_ROOT_PASSWORD="password"
DB_NAME="pollapp"
MYSQL_USER="root"

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
echo "MySQL Installation and Setup for Poll App"
echo "=========================================="
echo ""

# Step 1: Install MySQL
print_info "Step 1: Installing MySQL Server..."

if command -v mysql &> /dev/null; then
    print_success "MySQL is already installed"
    mysql --version
else
    print_info "Installing MySQL Server using yum..."
    yum update -y
    yum install -y mysql-server
    
    if [ $? -eq 0 ]; then
        print_success "MySQL Server installed successfully"
    else
        print_error "Failed to install MySQL Server"
        exit 1
    fi
fi

echo ""

# Step 2: Start and Enable MySQL Service
print_info "Step 2: Starting MySQL Service..."

systemctl start mysqld
systemctl enable mysqld

if systemctl is-active --quiet mysqld; then
    print_success "MySQL service is running"
else
    print_error "Failed to start MySQL service"
    exit 1
fi

echo ""

# Step 3: Configure Root Password
print_info "Step 3: Configuring MySQL root password..."

# Check if root password is already set
if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; then
    print_success "Root password is already configured"
else
    # Get temporary root password from log file (for fresh installations)
    TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log 2>/dev/null | awk '{print $NF}' | tail -1)
    
    if [ -n "$TEMP_PASSWORD" ]; then
        print_info "Found temporary password, setting new root password..."
        mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password <<EOF 2>/dev/null || true
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
    else
        # Try to set password if no temporary password found
        print_info "Setting root password..."
        mysql -u root <<EOF 2>/dev/null || true
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
    fi
    
    # Verify password was set
    if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; then
        print_success "Root password configured successfully"
    else
        print_error "Failed to configure root password"
        print_info "You may need to run: mysql_secure_installation"
        exit 1
    fi
fi

echo ""

# Step 4: Create Database
print_info "Step 4: Creating database '$DB_NAME'..."

mysql -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
EOF

if [ $? -eq 0 ]; then
    print_success "Database '$DB_NAME' created successfully"
else
    print_error "Failed to create database"
    exit 1
fi

echo ""

# Step 5: Create Tables
print_info "Step 5: Creating database tables..."

mysql -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" <<EOF
-- Disable foreign key checks during creation
SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS votes;
DROP TABLE IF EXISTS poll_options;
DROP TABLE IF EXISTS polls;
DROP TABLE IF EXISTS users;

-- Create users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create polls table
CREATE TABLE polls (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create poll_options table
CREATE TABLE poll_options (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    poll_id BIGINT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    \`order\` BIGINT NOT NULL DEFAULT 0,
    INDEX idx_poll_id (poll_id),
    FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create votes table
CREATE TABLE votes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    poll_id BIGINT NOT NULL,
    poll_option_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_poll_id (poll_id),
    INDEX idx_poll_option_id (poll_option_id),
    INDEX idx_user_id (user_id),
    UNIQUE KEY unique_user_poll (user_id, poll_id),
    FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE,
    FOREIGN KEY (poll_option_id) REFERENCES poll_options(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
EOF

if [ $? -eq 0 ]; then
    print_success "All tables created successfully"
else
    print_error "Failed to create tables"
    exit 1
fi

echo ""

# Step 6: Verify Installation
print_info "Step 6: Verifying installation..."

TABLE_COUNT=$(mysql -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" 2>/dev/null | wc -l)
TABLE_COUNT=$((TABLE_COUNT - 1))  # Subtract header row

if [ "$TABLE_COUNT" -eq 4 ]; then
    print_success "Verification successful: Found $TABLE_COUNT tables"
    echo ""
    print_info "Tables in database:"
    mysql -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" 2>/dev/null
else
    print_error "Verification failed: Expected 4 tables, found $TABLE_COUNT"
    exit 1
fi

echo ""
echo "=========================================="
print_success "MySQL setup completed successfully!"
echo "=========================================="
echo ""
echo "Database Details:"
echo "  Database Name: $DB_NAME"
echo "  Root Password: $MYSQL_ROOT_PASSWORD"
echo "  Connection: mysql -u root -p$MYSQL_ROOT_PASSWORD $DB_NAME"
echo ""
echo "You can now start the Poll App backend server!"
echo ""
