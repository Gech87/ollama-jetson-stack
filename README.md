# Ollama + Open WebUI on NVIDIA Jetson

A portable, self-contained setup for running Ollama with Open WebUI on NVIDIA Jetson devices (JetPack 7.2 / L4T 39.2.0).

## Features

- ✅ Runs Ollama with GPU acceleration on Jetson
- ✅ Open WebUI for a beautiful chat interface
- ✅ Portable folder structure (copy to any Jetson)
- ✅ Smart scripts (run multiple times safely)
- ✅ 8GB swap auto-configuration
- ✅ Multi-user support

## Folder Structure
ollama-stack/
```text
├── scripts/
│ ├── setup.sh  # First-time setup (idempotent)
│ ├── start.sh  # Daily start
│ └── stop.sh  # Daily stop
├── data/  # User data (models, chats) - KEEP PRIVATE
└── jetson-containers/  # Cloned during setup
```

## Quick Start

On a new Jetson device:

```bash
git clone https://github.com/YOUR_USERNAME/ollama-jetson-stack.git
cd ollama-jetson-stack/scripts
./setup.sh
```
Then open http://localhost:8080 in your browser.


## Hardware
- Device: NVIDIA Jetson (Orin/Nano/AGX)
- RAM: 7.3GB total, 8GB swap on 1TB storage
- OS: Ubuntu 24.04 (Noble)
- Architecture: ARM64

## Software Versions
- L4T: 39.2.0
- JetPack: 7.2
- CUDA: 13.2
- Docker: [check with `docker --version`]
- Ollama: 0.9.5 (in container: dustynv/ollama:r36.4-cu129-24.04)
- Open WebUI: latest (ghcr.io/open-webui/open-webui:main)

## Installed Models
- llama3.2:3b (pull command: `ollama pull llama3.2:3b`)

## Commands

|   Command          |     Description         |
|--------------------|-------------------------|
| ./scripts/start.sh | Start all services      |
| ./scripts/stop.sh  | Stop all services       |
| ./scripts/setup.sh | Full setup (first time) |

## Requirements
 - NVIDIA Jetson (Orin, Nano, AGX, etc.)
 - JetPack 7.2 or later
 - Docker with nvidia-runtime


## Adding Models
```bash
sudo docker exec ollama ollama pull llama3.2:3b
sudo docker exec ollama ollama pull mistral:7b
```
## License
MIT