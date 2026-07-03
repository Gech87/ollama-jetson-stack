#!/bin/bash

# Restore script for Ollama stack
# Usage: ./restore.sh [dev|acc|prd] [backup-file]

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./restore.sh [dev|acc|prd] [backup-file]"
    echo ""
    echo "Example:"
    echo "  ./restore.sh prd backups/ollama-prd-20240101_120000.tar.gz"
    exit 1
fi

ENV=$1
BACKUP_FILE=$2
STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "=== Restoring $ENV environment ==="

# Stop containers
echo "Stopping $ENV containers..."
sudo docker stop ollama-$ENV open-webui-$ENV 2>/dev/null || true
sudo docker rm ollama-$ENV open-webui-$ENV 2>/dev/null || true

# Restore data
echo "Restoring data from $BACKUP_FILE..."
cd "$STACK_DIR"
tar -xzf "$BACKUP_FILE"

# Deploy
echo "Deploying $ENV environment..."
./scripts/deploy.sh "$ENV"

echo "=== Restore complete! ==="