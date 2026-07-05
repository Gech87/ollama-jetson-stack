# Ollama + Open WebUI on NVIDIA Jetson

A production-ready, self-contained setup for running Ollama with Open WebUI on NVIDIA Jetson devices, featuring CI/CD, multi-environment deployment, and GPU acceleration.

---

## Table of Contents

- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Hardware and Software Requirements](#hardware-and-software-requirements)
- [Quick Start](#quick-start)
- [Folder Structure](#folder-structure)
- [Environment Management](#environment-management)
- [CI/CD Pipeline](#cicd-pipeline)
- [Daily Operations](#daily-operations)
- [Adding Models](#adding-models)
- [Backup and Recovery](#backup-and-recovery)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- GPU Acceleration: Full NVIDIA GPU support via nvidia-container-runtime
- Multi-Environment: Separate Dev (8081), Acc (8082), and Prd (8080) environments
- CI/CD Pipeline: Automated deployment on push to dev and main branches
- Tailscale Integration: Secure remote access without exposing ports
- Portable Setup: Copy the entire stack to any Jetson device
- Smart Scripts: Idempotent scripts that run safely multiple times
- 8GB Swap: Automatic swap configuration for memory-intensive models
- Multi-User Support: Open WebUI with admin-controlled user registration
- Model Management: Pull and manage multiple LLM models
- Data Persistence: Separate data volumes for each environment
- Health Monitoring: Automatic container health checks and restart policies

---

## Architecture Overview

## 🏗 Architecture Overview

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                                   │
│  (https://github.com/Gech87/ollama-jetson-stack)                            │
│                                                                             │
│  ├── .github/workflows/deploy.yml    # CI/CD pipeline                       │
│  ├── scripts/                         # Deployment scripts                  │
│  ├── docker/                          # Docker Compose files                │
│  └── data/                            # Data (excluded from git)            │
└─────────────────────────────┬───────────────────────────────────────────────┘
                              │
                              │ Push to dev/main
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GitHub Actions (Ubuntu Runner)                           │
│                                                                             │
│  1. Checkout code                                                           │ 
│  2. Connect to Tailscale                                                    │
│  3. SSH to Jetson                                                           │
│  4. Run deploy.sh for target environment                                    │
└─────────────────────────────┬───────────────────────────────────────────────┘
                              │
                              │ SSH over Tailscale (100.105.218.35)
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NVIDIA Jetson (192.168.1.115)                            │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        Ollama Stack                                   │  │
│  │                                                                       │  │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │  │
│  │  │              Docker Containers                                   │ │  │
│  │  │                                                                  │ │  │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │ │  │
│  │  │  │  ollama-prd  │  │  ollama-dev  │  │  ollama-acc  │            │ │  │
│  │  │  │  (port 11434)│  │  (port 11435)│  │  (port 11436)│            │ │  │
│  │  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘            │ │  │
│  │  │         │                 │                 │                    │ │  │
│  │  │  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐            │ │  │
│  │  │  │ open-webui   │  │ open-webui   │  │ open-webui   │            │ │  │
│  │  │  │    -prd      │  │    -dev      │  │    -acc      │            │ │  │
│  │  │  │  (port 8080) │  │  (port 8081) │  │  (port 8082) │            │ │  │
│  │  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘            │ │  │
│  │  │         │                 │                 │                    │ │  │
│  │  └─────────┼─────────────────┼─────────────────┼────────────────────┘ │  │
│  │            │                 │                 │                      │  │
│  │  ┌─────────▼─────────────────▼─────────────────▼───────────────────┐  │  │
│  │  │                        Data Volumes                             │  │  │
│  │  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐        │  │  │
│  │  │  │ data/prd/     │  │ data/dev/     │  │ data/acc/     │        │  │  │
│  │  │  │  ├─ ollama/   │  │  ├─ ollama/   │  │  ├─ ollama/   │        │  │  │
│  │  │  │  └─ open-webui│  │  └─ open-webui│  │  └─ open-webui│        │  │  │
│  │  │  └───────────────┘  └───────────────┘  └───────────────┘        │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        System Resources                               │  │
│  │  RAM: 7.3GB (3.9GB available)  |  Swap: 8GB  |  Storage: 1TB          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                              │
                              │ Users access via browser
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Users (Family Members)                            │
│                                                                             │
│  Production: http://192.168.1.115:8080 (or Tailscale IP)                    │
│  Development: http://192.168.1.115:8081                                     │
│  Acceptance: http://192.168.1.115:8082                                      │
└─────────────────────────────────────────────────────────────────────────────┘
```
---

## Hardware and Software Requirements

### Hardware

| Component | Specification |
|-----------|---------------|
| Device | NVIDIA Jetson (Orin Nano, Orin NX, AGX Orin, or similar) |
| RAM | 8GB minimum (16GB+ recommended for 7B+ models) |
| Storage | 1TB NVMe SSD (recommended) |
| Architecture | ARM64 (aarch64) |

### Software Versions

| Component | Version |
|-----------|---------|
| L4T | 39.2.0 |
| JetPack | 7.2 |
| CUDA | 13.2 |
| Ubuntu | 24.04 (Noble) |
| Docker | Latest with nvidia-runtime |
| Docker Compose | v1.29.2+ |
| Ollama | 0.9.5+ (inside dustynv/ollama:r36.4-cu129-24.04) |
| Open WebUI | Latest (ghcr.io/open-webui/open-webui:main) |
| Tailscale | Latest (for CI/CD access) |

### Installed Models

| Model | Size | Parameters | Use Case |
|-------|------|------------|----------|
| llama3.2:3b | 2.0 GB | 3B | General purpose chat |
| llama3.2:1b | 1.3 GB | 1B | Fast, lightweight responses |
| gemma3:1b | 815 MB | 1B | Google's efficient model |

---

## Quick Start

### On a New Jetson Device

```bash
git clone https://github.com/Gech87/ollama-jetson-stack.git
cd ollama-jetson-stack
./scripts/setup.sh
```

Then open your browser to:
- Production: http://localhost:8080
- Development: http://localhost:8081
- Acceptance: http://localhost:8082

### On the First Run

The setup.sh script will:

- Detect existing swap and skip if already configured
- Clone jetson-containers if not present
- Start Ollama container with GPU acceleration
- Pull the default model (llama3.2:3b)
- Start Open WebUI with user registration enabled
- Create the first admin account (you)

---

## Folder Structure

```text
ollama-jetson-stack/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── docker/
│   ├── docker-compose.dev.yml
│   ├── docker-compose.acc.yml
│   └── docker-compose.prd.yml
├── data/
│   ├── dev/
│   │   ├── ollama/
│   │   └── open-webui/
│   ├── acc/
│   │   ├── ollama/
│   │   └── open-webui/
│   └── prd/
│       ├── ollama/
│       └── open-webui/
├── scripts/
│   ├── setup.sh
│   ├── start.sh
│   ├── stop.sh
│   ├── deploy.sh
│   ├── backup.sh
│   └── restore.sh
├── .env/
│   ├── .env.dev
│   ├── .env.acc
│   └── .env.prd
├── .gitignore
├── README.md
└── LICENSE
```

### What Should Be in Git vs. Private

| Item | In Git? | Why |
|------|---------|-----|
| scripts/ | Yes | Publicly usable deployment scripts |
| docker/ | Yes | Compose files are public |
| .github/workflows/ | Yes | CI/CD pipeline is public |
| README.md | Yes | Documentation |
| data/ | No | Contains models, user accounts, chats (SENSITIVE) |
| .env/ | No | Contains secrets and passwords |
| backups/ | No | Personal backups |
| .gitignore | Yes | Tells git what to exclude |

---

## Environment Management

### Environment Overview

| Environment | Port | Purpose | Sign-up | Users | Data |
|-------------|------|---------|---------|-------|------|
| Dev | 8081 | Development and testing | Enabled | Developer only | Test data |
| Acc | 8082 | Staging and validation | Enabled | Testers | Copy of production |
| Prd | 8080 | Production | Disabled | Family members | Real data |

### Port Assignments

| Service | Dev | Acc | Prd |
|---------|-----|-----|-----|
| Ollama API | 11435 | 11436 | 11434 |
| Open WebUI | 8081 | 8082 | 8080 |

### Deployment Commands

```bash
./scripts/deploy.sh dev    # Development (port 8081)
./scripts/deploy.sh acc    # Acceptance (port 8082)
./scripts/deploy.sh prd    # Production (port 8080)
./scripts/deploy.sh all    # Deploy all environments
```

### Access URLs

| Environment | Local URL | Tailscale URL |
|-------------|-----------|---------------|
| Dev | http://localhost:8081 | http://100.105.218.35:8081 |
| Acc | http://localhost:8082 | http://100.105.218.35:8082 |
| Prd | http://localhost:8080 | http://100.105.218.35:8080 |

---

## CI/CD Pipeline

### GitHub Actions Workflow

| Trigger | Action |
|---------|--------|
| Push to dev branch | Deploys to Dev environment |
| Push to main branch | Deploys to Acc + Prd environments |
| Manual workflow_dispatch | Deploys to selected environment, optionally pulls a model |

### Required GitHub Secrets

| Secret Name | Description | Where to Get |
|-------------|-------------|--------------|
| SSH_PRIVATE_KEY | Private SSH key for GitHub to access Jetson | cat ~/.ssh/id_ed25519 |
| DEPLOY_HOST | Tailscale IP of Jetson | tailscale ip |
| DEPLOY_USER | Username on Jetson | whoami |
| TAILSCALE_AUTH_KEY | Tailscale auth key for GitHub runner | Tailscale admin console |

### CI/CD Flow

```text
1. Developer pushes code to GitHub
   git push origin dev

2. GitHub Actions triggers workflow
   - Checks out code
   - Validates secrets

3. Tailscale connects GitHub runner to your network
   - Runner joins your Tailscale network
   - Can now reach 100.105.218.35

4. SSH to Jetson
   - SSH key authentication
   - Runs commands without password (sudoers configured)

5. Deploy target environment
   - cd ~/Projects/ollama-stack
   - git pull (get latest code)
   - ./scripts/deploy.sh dev/acc/prd

6. Docker Compose deploys containers
   - Stops existing containers
   - Pulls latest images
   - Starts new containers with updated config
   - Mounts appropriate data volumes
```

---

## Daily Operations

### Start Services

```bash
./scripts/start.sh
# Or deploy a specific environment
./scripts/deploy.sh prd
```

### Stop Services

```bash
./scripts/stop.sh
```

### Check Status

```bash
sudo docker ps
sudo docker ps -a
sudo docker logs open-webui-prd
sudo docker logs ollama-prd
```

### Restart Services

```bash
./scripts/deploy.sh prd
sudo docker restart open-webui-prd
```

### Backup Data

```bash
./scripts/backup.sh all
./scripts/backup.sh prd
```

### Restore from Backup

```bash
./scripts/restore.sh prd ~/backups/ollama/prd-20240101_120000.tar.gz
```

---

## Adding Models

### Via Command Line

```bash
sudo docker exec ollama-prd ollama pull mistral:7b
sudo docker exec ollama-dev ollama pull mistral:7b
sudo docker exec ollama-acc ollama pull mistral:7b
```

### Via CI/CD (GitHub Actions)

1. Go to Actions tab
2. Click "Deploy Ollama Stack"
3. Click "Run workflow"
4. Set Branch, Model, and Environment
5. Click "Run workflow"

### Available Models

| Model | Size | RAM Required | Use Case |
|-------|------|--------------|----------|
| llama3.2:1b | 0.7 GB | ~1.5 GB | Fast, lightweight |
| gemma3:1b | 0.8 GB | ~1.5 GB | Google's efficient model |
| phi3:mini | 2.3 GB | ~3.5 GB | Microsoft's compact model |
| llama3.2:3b | 2.0 GB | ~3.4 GB | Good balance (recommended) |
| gemma3:4b | 2.6 GB | ~4.5 GB | Better reasoning |
| llama3:7b | 4.4 GB | ~5.5 GB | More capable (needs swap) |
| mistral:7b | 4.1 GB | ~5.2 GB | Good all-around |
| codellama:7b | 3.8 GB | ~5.0 GB | Coding tasks |
| qwen2.5:7b | 4.7 GB | ~5.8 GB | Chinese/English reasoning |

---

## Backup and Recovery

### Automated Backup

```text
Location: ~/backups/ollama/
Format: ollama-ENV-TIMESTAMP.tar.gz
Example: ollama-prd-20240101_120000.tar.gz
```

### Manual Backup

```bash
tar -czf prd-backup-$(date +%Y%m%d).tar.gz ~/Projects/ollama-stack/data/prd/
tar -czf openwebui-backup-$(date +%Y%m%d).tar.gz ~/Projects/ollama-stack/data/prd/open-webui/
```

### Restore from Backup

```bash
./scripts/stop.sh
tar -xzf backup.tar.gz -C ~/Projects/ollama-stack/
./scripts/deploy.sh prd
```

---

## Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Ollama container restarts | Check logs: sudo docker logs ollama-prd |
| address already in use | Different environments need different ports |
| WebUI won't load | Check if containers are running: sudo docker ps |
| Model not found | Pull the model: sudo docker exec ollama-prd ollama pull MODEL |
| Permission denied | sudo chown -R gustavocarro:gustavocarro ~/Projects/ollama-stack/ |
| Out of memory | Enable swap or use smaller model |
| SSH connection fails | Check Tailscale: tailscale status |
| sudo password in CI/CD | Configure NOPASSWD in sudoers |

### View Logs

```bash
sudo docker logs --tail 50 open-webui-prd
sudo docker logs --tail 50 ollama-prd
sudo docker logs -f open-webui-prd
```

### Reset an Environment

```bash
sudo docker stop ollama-dev open-webui-dev
sudo docker rm ollama-dev open-webui-dev
./scripts/deploy.sh dev
```

### Clean Up Docker

```bash
sudo docker system prune -a -f
sudo docker volume prune -f
```

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

### Development Workflow

```bash
git checkout -b feature/new-model
git push origin feature/new-model
git checkout dev
git merge feature/new-model
git push origin dev
git checkout main
git merge dev
git push origin main
```

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Acknowledgments

- dusty-nv/jetson-containers - Base container images
- Ollama - LLM runtime
- Open WebUI - Web interface
- Tailscale - Secure networking

---

## Support

If you encounter issues:

1. Check the Troubleshooting section
2. View container logs: sudo docker logs CONTAINER_NAME
3. Check GitHub Actions logs for CI/CD issues
4. Open an issue on GitHub

---

Last Updated: July 2026

Version: 1.0.0