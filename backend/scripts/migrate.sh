#!/bin/bash

# Database Migration Script
# This script runs the schema creation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the schema creation script
"$SCRIPT_DIR/create-schema.sh"
