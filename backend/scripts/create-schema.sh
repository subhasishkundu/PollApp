#!/bin/bash

# Database Schema Creation Script
# This script creates all tables for the Poll App
# Usage: ./create-schema.sh

set -e  # Exit on error

# Database credentials (can be overridden by environment variables)
DB_USER=${DB_USER:-root}
DB_PASSWORD=${DB_PASSWORD:-admin}
DB_NAME=${DB_NAME:-pollapp}

echo "Creating database schema for Poll App..."
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo ""

# Check if database exists, create if not
echo "Checking database..."
if ! mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME" 2>/dev/null; then
    echo "Creating database $DB_NAME..."
    mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"
    echo "✓ Database created"
else
    echo "✓ Database already exists"
fi

echo ""
echo "Creating tables..."

# Execute SQL commands
mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<EOF
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
    echo ""
    echo "✓ Schema created successfully!"
    echo ""
    echo "Verifying tables..."
    mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SHOW TABLES;"
    echo ""
    echo "✓ All tables created. You can now start the backend server."
else
    echo ""
    echo "✗ Schema creation failed!"
    exit 1
fi
