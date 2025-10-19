# AirGapAICoder Quick Start Guide

Get your air-gapped AI coding assistant running in 5 steps.

## Prerequisites

- **Server**: NVIDIA GPU with 24GB+ VRAM
- **Internet-connected system**: For preparation phase
- **Transfer medium**: USB drive (64GB+ recommended)
- **Network**: Local network connecting server and clients

## Choose Your Deployment Method

### Method 1: Traditional Installation (Recommended for First-Time Users)

Full control with manual installation scripts.

### Method 2: Container Deployment (Podman) - COMING SOON v1.1.0

Single-command deployment with GPU support.

### Method 3: AirAI CLI (Simplified) - COMING SOON v1.1.0

Professional CLI tool for management and deployment.

---

## Method 1: Traditional Installation

### Step 1: Prepare Package (Internet-Connected System)

**Linux/macOS:**
```bash
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Run preparation script (downloads Ollama + models)
cd scripts/preparation
./pull-all.sh

# For production models (47GB total):
export PULL_PRODUCTION_MODELS=true
./pull-all.sh

# Package created at ~/airgap-package
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder\scripts\preparation
.\pull-all.ps1
```

**What gets downloaded:**
- Ollama installer
- AI models (Qwen 2.5 Coder 32B, DeepSeek R1 32B, Qwen 14B)
- CUDA toolkit (if needed)
- VS Code and Cline extension (optional)

### Step 2: Transfer to Air-Gap Server

```bash
# Copy to USB drive
cp -r ~/airgap-package /Volumes/USB/

# On air-gap server, copy from USB
cp -r /media/USB/airgap-package ~/
```

**Transfer size:** ~47GB for all models

### Step 3: Install on Server

**Windows Server:**
```powershell
cd scripts\installation\server
.\install-windows.ps1 C:\airgap-package
```

**Ubuntu Server:**
```bash
cd scripts/installation/server
sudo ./install-ubuntu.sh ~/airgap-package
```

**macOS (Testing/Development):**
```bash
cd scripts/installation/server
./install-macos.sh ~/airgap-package
```

**Installation includes:**
- Ollama server
- GPU drivers (if needed)
- AI models with extended context (131k tokens)
- Network configuration (port 11434)
- Service auto-start

### Step 4: Verify Server

```bash
# Check server health
curl http://localhost:11434/api/tags

# From another machine on network
curl http://SERVER_IP:11434/api/tags

# List installed models
ollama list

# Expected output:
# qwen-32b-cline       19GB
# deepseek-r1-32b-cline 19GB
# qwen-14b-cline       9GB
```

### Step 5: Start Using AI!

#### Option A: Command Line (Any Terminal)

**Using CLI wrapper:**
```bash
./scripts/cli/ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline \
  "Write a Python function to calculate prime numbers"
```

**Using curl directly:**
```bash
curl http://SERVER_IP:11434/api/generate -d '{
  "model": "qwen-32b-cline",
  "prompt": "Write a REST API endpoint in Python FastAPI",
  "stream": false
}' | jq -r '.response'
```

**Using PowerShell:**
```powershell
Invoke-RestMethod http://SERVER_IP:11434/api/generate -Method POST -Body '{
  "model": "qwen-32b-cline",
  "prompt": "Create a React component for user login",
  "stream": false
}' -ContentType "application/json" | Select -ExpandProperty response
```

**From Python:**
```python
import requests

response = requests.post('http://SERVER_IP:11434/api/generate', json={
    'model': 'qwen-32b-cline',
    'prompt': 'Write a Python function to validate email addresses',
    'stream': False
})
print(response.json()['response'])
```

#### Option B: VS Code + Cline (Optional GUI)

If you prefer a graphical interface:

1. Install VS Code on client workstation
2. Install Cline extension from package
3. Configure: Settings → Base URL: `http://SERVER_IP:11434`
4. Start chatting in Cline sidebar

---

## Quick Usage Examples

### Code Generation

```bash
# Generate a complete module
./scripts/cli/ollama-cli.sh run SERVER:11434 qwen-32b-cline \
  "Create a Python class for managing a shopping cart with add, remove, checkout methods"

# Generate tests
./scripts/cli/ollama-cli.sh run SERVER:11434 qwen-32b-cline \
  "Write pytest tests for this function: $(cat mycode.py)"
```

### Code Review

```bash
# Review for bugs and security
curl http://SERVER:11434/api/generate -d "{
  \"model\": \"qwen-32b-cline\",
  \"prompt\": \"Review this code for bugs and security issues: $(cat app.py)\",
  \"stream\": false
}" | jq -r '.response'
```

### Refactoring

```bash
# Modernize code
./scripts/cli/ollama-cli.sh run SERVER:11434 deepseek-r1-32b-cline \
  "Refactor this code to use async/await and add error handling: $(cat sync_code.py)"
```

### Documentation

```bash
# Generate docstrings
./scripts/cli/ollama-cli.sh run SERVER:11434 qwen-32b-cline \
  "Add comprehensive docstrings to: $(cat module.py)" > documented_module.py
```

---

## Success!

You now have a fully functional, air-gapped AI coding assistant accessible from:
- Any terminal on any platform
- Any programming language via HTTP API
- VS Code with Cline extension (optional)
- Anywhere on your local network

**No cloud required. No subscriptions. No data leakage. Complete control.**

---

## Next Steps

### Learn More

- **[CLI Usage Guide](CLI-USAGE.md)** - Terminal usage examples for all platforms
- **[Client Usage Guide](CLIENT-USAGE.md)** - VS Code + Cline setup
- **[Server Setup Guide](SERVER-SETUP.md)** - Advanced server configuration
- **[Operations Guide](OPERATIONS.md)** - Maintenance and troubleshooting

### Advanced Features

- **Model Selection**: Switch between Qwen (code) and DeepSeek (reasoning)
- **Extended Context**: 131k token windows for large codebases
- **Multi-User**: Multiple developers on the network
- **Monitoring**: Health checks and performance tracking

### Common Issues

**Server not responding?**
```powershell
# Windows: Restart Ollama
Stop-Process -Name "ollama" -Force
Start-Process "ollama" -ArgumentList "serve"
```

**GPU not detected?**
```bash
# Verify GPU
nvidia-smi

# Check CUDA
nvcc --version
```

**Clients can't connect?**
```powershell
# Check firewall (Windows)
Get-NetFirewallRule -DisplayName "Ollama"

# Verify server listening
netstat -an | findstr "11434"
```

---

## Coming Soon (v1.1.0)

### Method 2: Container Deployment

```bash
# Build container with GPU support
airai container build

# Run with single command
airai container run --gpus all --port 11434

# Export for air-gap
airai container export --output airgap-ollama.tar
```

### Method 3: AirAI CLI

```bash
# Simple commands
airai health
airai models list
airai chat qwen-32b-cline "write code"
airai package prepare
```

Stay tuned for updates at [github.com/fuzemobi/AirGapAICoder](https://github.com/fuzemobi/AirGapAICoder)

---

**Version:** 1.0.2
**Author:** Fuzemobi, LLC - Chad Rosenbohm
**License:** MIT
