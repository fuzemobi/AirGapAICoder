# Container Deployment Guide

Deploy AirGapAICoder using Podman or Docker containers for simplified setup and management.

## Overview

Containerized deployment provides:
- Single-command deployment
- GPU passthrough support
- Isolated environment
- Easy updates and rollbacks
- Perfect for air-gap environments

## Prerequisites

### Software Requirements
- **Podman 4.0+** or **Docker 20.10+**
- **NVIDIA Container Toolkit** (for GPU support)
- **NVIDIA Drivers** 525.60.13+
- **Python 3.9+** (for AirAI CLI)

### Hardware Requirements
- **GPU**: NVIDIA with 24GB+ VRAM
- **RAM**: 32GB+ system memory
- **Storage**: 100GB+ free space
- **Network**: Local network access

## Installation

### Step 1: Install Container Runtime

**Podman (Recommended for Air-Gap):**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y podman

# Fedora/RHEL
sudo dnf install -y podman

# macOS
brew install podman
podman machine init
podman machine start
```

**Docker (Alternative):**
```bash
# Ubuntu
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER
```

### Step 2: Install NVIDIA Container Toolkit

```bash
# Add repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configure for Podman
sudo nvidia-ctk runtime configure --runtime=podman
sudo systemctl restart podman

# Or for Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Step 3: Verify GPU Access

```bash
# Podman
podman run --rm --device nvidia.com/gpu=all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Docker
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

## Internet-Connected Deployment

### Build Container

```bash
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Build with Podman
./scripts/container/build.sh

# Or with Docker
CONTAINER_RUNTIME=docker ./scripts/container/build.sh
```

### Run Container

```bash
# Run with Podman
./scripts/container/run.sh

# Or with Docker
CONTAINER_RUNTIME=docker ./scripts/container/run.sh

# Custom configuration
IMAGE_NAME=my-ollama \
PORT=8080 \
MODELS_DIR=/data/models \
./scripts/container/run.sh
```

### Verify Running Container

```bash
# Check container status
podman ps

# View logs
podman logs -f airgap-ollama-server

# Test API
curl http://localhost:11434/api/tags
```

## Air-Gap Deployment

### On Internet-Connected System

```bash
# 1. Build container
./scripts/container/build.sh

# 2. Export container image
./scripts/container/deploy-airgap.sh

# Package created at: ~/airgap-package/container/
# Contents:
#   - airgap-ollama-latest.tar (~2GB)
#   - load-and-run.sh (deployment script)
```

### Transfer to Air-Gap System

```bash
# Copy to USB drive
cp -r ~/airgap-package/container /media/usb/

# On air-gap system
cp -r /media/usb/container ~/
```

### On Air-Gap System

```bash
cd ~/container

# Load and run
./load-and-run.sh

# Or manually:
podman load -i airgap-ollama-latest.tar
podman run -d \
    --name airgap-ollama-server \
    --device nvidia.com/gpu=all \
    -p 11434:11434 \
    -v $HOME/.ollama/models:/root/.ollama/models:Z \
    airgap-ollama:latest
```

## Container Management

### Start/Stop

```bash
# Stop
podman stop airgap-ollama-server

# Start
podman start airgap-ollama-server

# Restart
podman restart airgap-ollama-server

# Remove
podman rm -f airgap-ollama-server
```

### View Logs

```bash
# Real-time logs
podman logs -f airgap-ollama-server

# Last 100 lines
podman logs --tail 100 airgap-ollama-server
```

### Shell Access

```bash
# Execute commands
podman exec airgap-ollama-server ollama list

# Interactive shell
podman exec -it airgap-ollama-server bash
```

### Update Container

```bash
# Pull new image
podman pull airgap-ollama:latest

# Stop old container
podman stop airgap-ollama-server
podman rm airgap-ollama-server

# Run new version
./scripts/container/run.sh
```

## Model Management

### Pre-load Models in Container

```bash
# Enter container
podman exec -it airgap-ollama-server bash

# Inside container
ollama pull qwen2.5-coder:32b-instruct-fp16
ollama pull deepseek-r1:32b

# Create custom models with extended context
ollama create qwen-32b-cline -f /config/Modelfile-qwen32b
```

### Persist Models

Models are automatically persisted in the mounted volume:
- Host: `$HOME/.ollama/models`
- Container: `/root/.ollama/models`

## Using AirAI CLI with Container

### Installation

```bash
# Install AirAI CLI
pip install -e .

# Or from wheel
pip install dist/airai-*.whl
```

### Usage

```bash
# Check container health
airai health

# List models
airai models list

# Chat with AI
airai chat qwen-32b-cline "Write a function"

# Code review
airai code review src/

# Edit files with AI
airai code edit app.py "add error handling"
```

## Advanced Configuration

### Custom Environment Variables

```bash
podman run -d \
    --name airgap-ollama-server \
    --device nvidia.com/gpu=all \
    -p 11434:11434 \
    -v $HOME/.ollama/models:/root/.ollama/models:Z \
    -e OLLAMA_NUM_PARALLEL=2 \
    -e OLLAMA_MAX_LOADED_MODELS=2 \
    -e OLLAMA_FLASH_ATTENTION=1 \
    airgap-ollama:latest
```

### Using Podman Compose

Create `podman-compose.yml`:
```yaml
version: '3.8'

services:
  ollama:
    image: airgap-ollama:latest
    container_name: airgap-ollama-server
    devices:
      - nvidia.com/gpu=all
    ports:
      - "11434:11434"
    volumes:
      - ollama-models:/root/.ollama/models
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
      - OLLAMA_NUM_PARALLEL=1
      - OLLAMA_MAX_LOADED_MODELS=1
    restart: unless-stopped

volumes:
  ollama-models:
```

Run with:
```bash
podman-compose up -d
```

### Resource Limits

```bash
# CPU and memory limits
podman run -d \
    --name airgap-ollama-server \
    --device nvidia.com/gpu=all \
    --cpus=8 \
    --memory=32g \
    -p 11434:11434 \
    airgap-ollama:latest
```

## Troubleshooting

### GPU Not Detected

```bash
# Verify NVIDIA runtime
podman run --rm --device nvidia.com/gpu=all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Check container toolkit
nvidia-ctk --version

# Reconfigure toolkit
sudo nvidia-ctk runtime configure --runtime=podman
```

### Container Won't Start

```bash
# Check logs
podman logs airgap-ollama-server

# Verify image
podman images airgap-ollama

# Remove and recreate
podman rm -f airgap-ollama-server
./scripts/container/run.sh
```

### Port Already in Use

```bash
# Find process using port
sudo lsof -i :11434

# Run on different port
PORT=8080 ./scripts/container/run.sh
```

### Permission Denied

```bash
# Add user to podman group
sudo usermod -aG podman $USER
newgrp podman

# Or run with sudo
sudo podman run ...
```

## Performance Tuning

### GPU Optimization

```bash
# Use specific GPU
podman run --device nvidia.com/gpu=0 ...

# Multiple GPUs
podman run --device nvidia.com/gpu=all ...
```

### Model Caching

```bash
# Pre-load models for faster startup
podman exec airgap-ollama-server ollama pull qwen-32b-cline
podman exec airgap-ollama-server ollama pull deepseek-r1-32b-cline
```

### Network Performance

```bash
# Use host networking (better performance)
podman run --network=host airgap-ollama:latest
```

## Security Considerations

### Container Isolation

- Containers run in isolated namespaces
- Limited access to host system
- Models stored in mounted volumes

### Network Security

```bash
# Bind to localhost only
podman run -p 127.0.0.1:11434:11434 ...

# Or use firewall rules
sudo ufw allow from 192.168.1.0/24 to any port 11434
```

### Updates

```bash
# Regularly rebuild containers
./scripts/container/build.sh

# Export for air-gap systems
./scripts/container/deploy-airgap.sh
```

## Next Steps

- [AirAI CLI Documentation](../src/airai/README.md)
- [AirAI + Cline Integration](AIRAI-CLINE-INTEGRATION.md)
- [Quickstart Guide](QUICKSTART.md)
- [Operations Guide](OPERATIONS.md)

---

**Version:** 1.1.0  
**Author:** Fuzemobi, LLC - Chad Rosenbohm  
**License:** MIT
