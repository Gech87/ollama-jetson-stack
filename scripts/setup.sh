#!/bin/bash

# This script sets up Ollama + Open WebUI on a Jetson device
# It works on any username because it uses ~ (home directory)
# It can be run multiple times safely (idempotent)

set -e  # Stop if any command fails

echo "=== Starting Ollama + Open WebUI Setup ==="

# Get the stack directory (where this script lives)
STACK_DIR="$HOME/Projects/ollama-stack"
DATA_DIR="$STACK_DIR/data"

# 1. Enable 8GB swap file (only if not already configured)
echo "Step 1: Checking swap..."
if swapon --show | grep -q "/swapfile"; then
    echo "  ✓ Swap already configured. Skipping."
else
    echo "  Creating 8GB swap file..."
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "  ✓ Swap created."
fi

# 2. Clone jetson-containers (only if it doesn't exist)
echo "Step 2: Checking jetson-containers..."
if [ -d "$STACK_DIR/jetson-containers" ]; then
    echo "  ✓ jetson-containers already exists. Skipping clone."
else
    echo "  Cloning jetson-containers..."
    cd "$STACK_DIR"
    git clone https://github.com/dusty-nv/jetson-containers
    cd jetson-containers
    bash install.sh
    echo "  ✓ Clone and install complete."
fi

# 3. Start Ollama container (only if not already running)
echo "Step 3: Starting Ollama container..."
if sudo docker ps --format '{{.Names}}' | grep -q "^ollama$"; then
    echo "  ✓ Ollama container is already running."
else
    # Remove existing container if stopped
    sudo docker rm -f ollama 2>/dev/null || true
    sudo docker run -d --runtime nvidia \
      --name ollama \
      --network host \
      --shm-size=8g \
      --restart unless-stopped \
      -v "$DATA_DIR/ollama:/data" \
      dustynv/ollama:r36.4-cu129-24.04 \
      /bin/bash -c "ollama serve"
    echo "  ✓ Ollama container started."
fi

# 4. Wait for Ollama to start
echo "Step 4: Waiting 10 seconds for Ollama to initialize..."
sleep 10

# 5. Pull the model (only if not already present)
echo "Step 5: Checking for llama3.2:3b model..."
if sudo docker exec ollama ollama list 2>/dev/null | grep -q "llama3.2:3b"; then
    echo "  ✓ Model llama3.2:3b already exists. Skipping pull."
else
    echo "  Pulling llama3.2:3b model..."
    sudo docker exec ollama ollama pull llama3.2:3b
    echo "  ✓ Model pulled successfully."
fi

# 6. Start Open WebUI (only if not already running)
echo "Step 6: Starting Open WebUI..."
if sudo docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
    echo "  ✓ Open WebUI is already running."
else
    sudo docker rm -f open-webui 2>/dev/null || true
    sudo docker run -d --network=host \
      --name open-webui \
      --restart unless-stopped \
      -v "$DATA_DIR/open-webui:/app/backend/data" \
      -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
      -e ENABLE_SIGNUP=true \
      -e DEFAULT_USER_ROLE=pending \
      ghcr.io/open-webui/open-webui:main
    echo "  ✓ Open WebUI started."
fi

echo ""
echo "=== Setup Complete! ==="
echo "Open your browser to: http://localhost:8080"
echo "The first account you create becomes the admin"
echo ""
echo "Stack location: $STACK_DIR"
echo "Data location: $DATA_DIR"