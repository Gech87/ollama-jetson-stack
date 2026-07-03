#!/bin/bash

# Backup script for Ollama stack
# Usage: ./backup.sh [dev|acc|prd|all]

set -e

BACKUP_DIR="$HOME/backups/ollama"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$BACKUP_DIR"

backup_env() {
    ENV=$1
    DATA_DIR="$STACK_DIR/data/$ENV"
    BACKUP_FILE="$BACKUP_DIR/ollama-$ENV-$TIMESTAMP.tar.gz"
    
    if [ -d "$DATA_DIR" ]; then
        echo "Backing up $ENV environment..."
        tar -czf "$BACKUP_FILE" -C "$STACK_DIR" "data/$ENV"
        echo "  ✓ Created: $BACKUP_FILE"
        echo "  Size: $(du -h "$BACKUP_FILE" | cut -f1)"
    else
        echo "  ✗ No data found for $ENV"
    fi
}

if [ "$1" = "all" ] || [ -z "$1" ]; then
    backup_env "dev"
    backup_env "acc"
    backup_env "prd"
else
    backup_env "$1"
fi

echo ""
echo "Backup completed."
echo "Location: $BACKUP_DIR"