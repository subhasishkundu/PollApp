#!/bin/bash

# Database Migration Script
# This script creates the database schema

echo "Running database migrations..."

# Database credentials (update if needed)
DB_USER=${DB_USER:-root}
DB_PASSWORD=${DB_PASSWORD:-admin}
DB_NAME=${DB_NAME:-pollapp}

# Check if database exists
if ! mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME" 2>/dev/null; then
    echo "Creating database $DB_NAME..."
    mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"
fi

# Run migration script
echo "Creating tables..."
mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$(dirname "$0")/create-schema.sql"

if [ $? -eq 0 ]; then
    echo "✓ Database schema created successfully!"
    echo "You can now start the backend server."
else
    echo "✗ Migration failed!"
    exit 1
fi
