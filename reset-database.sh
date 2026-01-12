#!/bin/bash

# Database reset script
# This script will clean all data from the pollapp database

echo "Resetting pollapp database..."
echo "Warning: This will delete ALL data from the database!"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Database credentials (update if needed)
DB_USER=${DB_USER:-root}
DB_PASSWORD=${DB_PASSWORD:-admin}
DB_NAME=${DB_NAME:-pollapp}

echo "Connecting to database..."
mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < backend/scripts/reset-db.sql

if [ $? -eq 0 ]; then
    echo "Database reset successful!"
    echo "All tables have been cleared."
else
    echo "Error: Database reset failed!"
    exit 1
fi
