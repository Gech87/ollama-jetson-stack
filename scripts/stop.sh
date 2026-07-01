#!/bin/bash

# Stop Ollama + Open WebUI (only if running)

echo "Stopping services..."

# Stop Ollama if running
if sudo docker ps --format '{{.Names}}' | grep -q "^ollama$"; then
    sudo docker stop ollama
    echo "  ✓ Ollama stopped"
else
    echo "  Ollama not running"
fi

# Stop Open WebUI if running
if sudo docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
    sudo docker stop open-webui
    echo "  ✓ Open WebUI stopped"
else
    echo "  Open WebUI not running"
fi

echo "Services stopped"