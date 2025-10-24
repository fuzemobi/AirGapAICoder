# Docker Quickstart Guide

Get AirGapAICoder running with Docker or Podman in minutes.

**Version:** 1.2.0  
**Author:** Fuzemobi, LLC - Chad Rosenbohm

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start (5 Minutes)](#quick-start-5-minutes)
- [Platform-Specific Setup](#platform-specific-setup)
- [Docker Compose Deployment](#docker-compose-deployment)
- [Air-Gap Deployment](#air-gap-deployment)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Docker 20.10+** or **Podman 4.0+**
- **NVIDIA GPU** with 24GB+ VRAM
- **NVIDIA Container Toolkit** (for GPU support)
- **32GB+ RAM**
- **100GB+ free disk space**

### Install Docker

**Windows:**
- Download [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- Install and restart
- Enable WSL 2 integration if prompted

**macOS:**
- Download [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
- Install and start Docker Desktop

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

### Install NVIDIA Container Toolkit (Linux)

```bash
# Add NVIDIA repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configure and restart Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Verify GPU Access

```bash
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

---

## Quick Start (5 Minutes)

### Method 1: Docker Compose (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# 2. Start with Docker Compose
docker-compose up -d

# 3. Wait for container to be healthy (30-60 seconds)
docker-compose ps

# 4. Test the API
curl http://localhost:11434/api/tags

# 5. View logs
docker-compose logs -f
```

**That's it!** Ollama is now running at `http://localhost:11434`

### Method 2: Direct Docker Run

```bash
# 1. Build the image
./scripts/docker/build-all-platforms.sh

# 2. Run the container
docker run -d \
    --name airgap-ollama-server \
    --gpus all \
    -p 11434:11434 \
    -v $HOME/.ollama/models:/root/.ollama/models \
    airgap-ollama:latest

# 3. Test
curl http://localhost:11434/api/tags
```

---

## Platform-Specific Setup

### Windows with Docker Desktop

```powershell
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Start with Docker Compose
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f
```

**Note:** Ensure Docker Desktop has access to your GPU in Settings → Resources → GPU

### macOS with Docker Desktop

```bash
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# macOS doesn't support NVIDIA GPUs with Docker
# Run without GPU (CPU-only, slower)
docker-compose up -d

# Or deploy on a remote Linux server with GPU
```

### Linux with Podman

```bash
# Install Podman
sudo apt-get install -y podman

# Install NVIDIA Container Toolkit
sudo nvidia-ctk runtime configure --runtime=podman
sudo systemctl restart podman

# Clone and run
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Use Podman instead of Docker
podman-compose up -d
# OR
CONTAINER_RUNTIME=podman ./scripts/container/run.sh
```

---

## Docker Compose Deployment

### Basic Deployment

```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs (follow mode)
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Custom Configuration

Create a `.env` file in the project root:

```env
# Port configuration
OLLAMA_PORT=11434

# Performance tuning
OLLAMA_NUM_PARALLEL=1
OLLAMA_MAX_LOADED_MODELS=1
OLLAMA_FLASH_ATTENTION=1

# Model storage
HOST_MODELS_DIR=/data/ollama/models
```

Then start:

```bash
docker-compose up -d
```

### Useful Docker Compose Commands

```bash
# Rebuild and restart
docker-compose up -d --build

# View resource usage
docker-compose top

# Execute commands in container
docker-compose exec ollama ollama list
docker-compose exec ollama airai --version

# Scale services (if configured)
docker-compose up -d --scale ollama=2

# Export logs
docker-compose logs > airgap-logs.txt
```

---

## Air-Gap Deployment

### On Internet-Connected System

```bash
# 1. Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# 2. Build the image
docker-compose build

# 3. Export for air-gap
./scripts/docker/export-airgap.sh

# This creates: ~/airgap-package/airgap-package-YYYYMMDD.tar.gz
# Transfer this file to your air-gap system via USB
```

### On Air-Gap System

```bash
# 1. Transfer and extract package
tar -xzf airgap-package-*.tar.gz
cd airgap-package/container

# 2. Run deployment script
./load-and-run.sh

# 3. Verify deployment
curl http://localhost:11434/api/tags
```

---

## Troubleshooting

### Container Won't Start

```bash
# Check Docker is running
docker ps

# Check logs for errors
docker-compose logs ollama

# Rebuild image
docker-compose build --no-cache
docker-compose up -d
```

### GPU Not Detected

```bash
# Verify NVIDIA drivers
nvidia-smi

# Verify Docker GPU access
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Check NVIDIA Container Toolkit
nvidia-ctk --version

# Reconfigure toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Port Already in Use

```bash
# Find process using port 11434
sudo lsof -i :11434

# Or use different port
OLLAMA_PORT=8080 docker-compose up -d
```

### Out of Memory

```bash
# Check available GPU memory
nvidia-smi

# Check system memory
free -h

# Reduce concurrent models
echo "OLLAMA_MAX_LOADED_MODELS=1" >> .env
docker-compose down
docker-compose up -d
```

### Models Not Loading

```bash
# Check models directory
docker-compose exec ollama ls -la /root/.ollama/models

# Download models (if internet available)
docker-compose exec ollama ollama pull qwen2.5-coder:32b

# Or mount existing models
# Edit docker-compose.yml to point to your models directory
```

### Container Keeps Restarting

```bash
# Check health check status
docker inspect airgap-ollama-server | grep -A 10 Health

# View detailed logs
docker logs airgap-ollama-server --tail 100

# Disable restart policy temporarily
docker update --restart=no airgap-ollama-server
```

### Performance Issues

```bash
# Monitor GPU utilization
nvidia-smi -l 1

# Monitor container resources
docker stats airgap-ollama-server

# Check for thermal throttling
nvidia-smi --query-gpu=temperature.gpu --format=csv -l 1

# Increase resource limits (edit docker-compose.yml)
```

---

## Next Steps

### Download Models

```bash
# Enter container
docker-compose exec ollama bash

# Inside container, pull models
ollama pull qwen2.5-coder:32b-instruct-fp16
ollama pull deepseek-r1:32b
ollama pull qwen2.5-coder:14b

# Create custom models with extended context
ollama create qwen-32b-cline -f /etc/ollama/modelfiles/Modelfile-qwen32b

# Exit container
exit
```

### Test AI Generation

```bash
# Simple test
curl http://localhost:11434/api/generate -d '{
  "model": "qwen-32b-cline",
  "prompt": "Write a Python function to calculate fibonacci numbers",
  "stream": false
}'

# With AirAI CLI (if installed)
docker-compose exec ollama airai chat qwen-32b-cline "Write a hello world program"
```

### Configure VS Code + Cline

See [CLIENT-USAGE.md](CLIENT-USAGE.md) for VS Code and Cline setup instructions.

### Production Deployment

For production deployments, see:
- [CONTAINER-DEPLOYMENT.md](CONTAINER-DEPLOYMENT.md) - Comprehensive deployment guide
- [OPERATIONS.md](OPERATIONS.md) - Operations and maintenance
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture

---

## Common Workflows

### Development Workflow

```bash
# Start services
docker-compose up -d

# Develop and test...

# View logs
docker-compose logs -f

# Restart after code changes
docker-compose restart

# Stop when done
docker-compose down
```

### Update Workflow

```bash
# Pull latest changes
git pull

# Rebuild image
docker-compose build

# Restart with new image
docker-compose down
docker-compose up -d
```

### Backup Workflow

```bash
# Backup models
tar -czf ollama-models-backup.tar.gz ~/.ollama/models

# Backup configuration
tar -czf airgap-config-backup.tar.gz config/

# Export image
docker save airgap-ollama:latest | gzip > airgap-ollama-latest.tar.gz
```

---

## Support

- **Documentation:** [docs/](.)
- **Issues:** [GitHub Issues](https://github.com/fuzemobi/AirGapAICoder/issues)
- **Discussions:** [GitHub Discussions](https://github.com/fuzemobi/AirGapAICoder/discussions)

---

**License:** MIT  
**Author:** Fuzemobi, LLC - Chad Rosenbohm  
**Version:** 1.2.0
