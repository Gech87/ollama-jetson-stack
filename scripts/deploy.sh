#!/bin/bash

# Deploy script for Ollama stack
# Usage: ./deploy.sh [dev|acc|prd]

set -e

# Check environment argument
if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh [dev|acc|prd]"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh dev   # Deploy development environment"
    echo "  ./deploy.sh acc   # Deploy acceptance/staging"
    echo "  ./deploy.sh prd   # Deploy production"
    exit 1
fi

ENV=$1
STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_DIR="$STACK_DIR/docker"
DATA_DIR="$STACK_DIR/data/$ENV"

# Port mapping for WebUI
case $ENV in
    dev)
        WEBUI_PORT=8081
        ;;
    acc)
        WEBUI_PORT=8082
        ;;
    prd)
        WEBUI_PORT=8080
        ;;
    *)
        echo "Unknown environment: $ENV"
        exit 1
        ;;
esac

echo "=== Deploying $ENV environment on port $WEBUI_PORT ==="

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR/ollama"
mkdir -p "$DATA_DIR/open-webui"

# Stop existing containers for this environment (using project name)
echo "Stopping existing $ENV containers..."
sudo docker-compose -p "ollama-$ENV" -f "$DOCKER_DIR/docker-compose.$ENV.yml" down 2>/dev/null || true

# Deploy with docker-compose (separate project for each environment)
echo "Starting $ENV containers..."
cd "$DOCKER_DIR"
sudo docker-compose -p "ollama-$ENV" -f "docker-compose.$ENV.yml" up -d

# Wait for services to start
echo "Waiting 15 seconds for services to initialize..."
sleep 15

# Check status
echo ""
echo "=== Deployment complete! ==="
echo "Environment: $ENV"
echo "Open WebUI: http://localhost:$WEBUI_PORT"
echo ""
echo "Container status:"
sudo docker ps --filter "name=ollama-$ENV" --filter "name=open-webui-$ENV"

# Show model list if it's production
if [ "$ENV" = "prd" ]; then
    echo ""
    echo "Models available in $ENV:"
    sudo docker exec ollama-$ENV ollama list 2>/dev/null || echo "  (Unable to list models)"
fi