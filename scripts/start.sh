#!/bin/bash

# Start Ollama + Open WebUI (if containers exist, use docker start)

STACK_DIR="$HOME/Projects/ollama-stack"
DATA_DIR="$STACK_DIR/data"

echo "=== Starting services ==="

# Check if Ollama container exists
if sudo docker ps -a --format '{{.Names}}' | grep -q "^ollama$"; then
    # Container exists, just start it
    sudo docker start ollama
    echo "  ✓ Ollama started"
else
    # Container doesn't exist, create it
    echo "  Creating new Ollama container..."
    sudo docker run -d --runtime nvidia \
      --name ollama \
      --network host \
      --shm-size=8g \
      --restart unless-stopped \
      -v "$DATA_DIR/ollama:/data" \
      dustynv/ollama:r36.4-cu129-24.04 \
      /bin/bash -c "ollama serve"
    echo "  ✓ Ollama created and started"
fi

# Check if Open WebUI container exists
if sudo docker ps -a --format '{{.Names}}' | grep -q "^open-webui$"; then
    sudo docker start open-webui
    echo "  ✓ Open WebUI started"
else
    echo "  Creating new Open WebUI container..."
    sudo docker run -d --network=host \
      --name open-webui \
      --restart unless-stopped \
      -v "$DATA_DIR/open-webui:/app/backend/data" \
      -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
      ghcr.io/open-webui/open-webui:main
    echo "  ✓ Open WebUI created and started"
fi

echo ""
echo "Services started"
echo "Open WebUI: http://localhost:8080"