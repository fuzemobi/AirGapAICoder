# AirAI CLI

Professional command-line interface for AirGapAICoder - Enterprise air-gapped AI coding assistant.

## Overview

AirAI is a powerful CLI tool for managing Ollama servers and interacting with AI models in air-gapped environments. Built with Python, Click, and Rich for beautiful terminal output.

## Features

- **Server Management**: Start, stop, and monitor Ollama servers
- **Model Operations**: List, pull, and manage AI models
- **AI Interaction**: Chat with models, get code assistance
- **File Operations**: AI-assisted code editing, review, and testing
- **Container Support**: Build and deploy Podman/Docker containers
- **Air-Gap Packaging**: Prepare deployments for offline environments
- **Health Monitoring**: Check server status and GPU utilization
- **Cross-Platform**: Works on Windows, macOS, and Linux

## Installation

### Quick Install (Recommended)

**Windows (PowerShell - Run as Administrator):**
```powershell
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Run automated installer
.\scripts\installation\install-airai-windows.ps1

# Restart terminal and verify
airai --version
```

**macOS / Linux (bash/zsh):**
```bash
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Run automated installer
./scripts/installation/install-airai.sh

# Restart terminal and verify
airai --version
```

The automated installers will:
- ✅ Check for Python 3.9+ (prompt to install if missing)
- ✅ Ensure pip is available
- ✅ Install AirAI CLI globally
- ✅ Verify installation and provide helpful next steps

### Manual Installation (Development)

```bash
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Install in development mode
pip install -e .

# Verify installation
airai --version
```

### Air-Gap Deployment (Offline Systems)

```bash
# On internet-connected system:
# 1. Build wheel
python -m build

# 2. Transfer wheel to air-gap system via USB

# On air-gap system:
# Windows
.\scripts\installation\install-airai-windows.ps1 -WheelPath "path\to\airai-1.1.0-py3-none-any.whl"

# macOS/Linux
WHEEL_PATH="path/to/airai-1.1.0-py3-none-any.whl" ./scripts/installation/install-airai.sh
```

### Uninstall

**Windows:**
```powershell
.\scripts\installation\uninstall-airai-windows.ps1
```

**macOS / Linux:**
```bash
./scripts/installation/uninstall-airai.sh
```

## Quick Start

```bash
# Check server health
airai health

# List available models
airai models list

# Chat with AI
airai chat qwen-32b-cline "Write a Python hello world function"

# Quick question
airai ask qwen-32b-cline "What is a closure?"

# Review code
airai code review src/

# Edit file with AI
airai code edit myfile.py "refactor to use async/await"
```

## Commands

### Server Management

```bash
airai server status          # Check server status
airai server start           # Start Ollama server
airai server stop            # Stop Ollama server
airai server restart         # Restart server
```

### Model Operations

```bash
airai models list            # List installed models
airai models pull MODEL      # Pull model from registry
airai models show MODEL      # Show model details
airai models remove MODEL    # Remove a model
```

### AI Interaction

```bash
airai chat MODEL "prompt"                    # Chat with AI
airai ask MODEL "question"                   # Quick question
airai code edit FILE "instructions"          # AI-assisted edit
airai code review PATH                       # Code review
airai code fix FILE                          # AI-guided fix
airai code test FILE                         # Generate tests
```

### Health & Monitoring

```bash
airai health                 # Server health check
airai health --watch         # Continuous monitoring
airai health gpu             # GPU-specific check
```

### Container Operations

```bash
airai container build        # Build container image
airai container run          # Run container
airai container stop         # Stop container
airai container export       # Export for air-gap
```

### Air-Gap Packaging

```bash
airai package prepare        # Prepare air-gap package
airai package verify PATH    # Verify package integrity
```

## Configuration

AirAI looks for configuration in the following locations (in order):

1. `./airai.yaml` (project-local)
2. `~/.airai/config.yaml` (user)
3. `/etc/airai/config.yaml` (system)

### Example Configuration

```yaml
# ~/.airai/config.yaml
server:
  host: "localhost"
  port: 11434
  timeout: 300

defaults:
  model: "qwen-32b-cline"
  temperature: 0.2
  num_ctx: 131072

airgap:
  package_dir: "~/airgap-package"
  models:
    - "qwen2.5-coder:32b-instruct-fp16"
    - "deepseek-r1:32b"
    - "qwen2.5-coder:14b"

container:
  runtime: "podman"  # or "docker"
  image: "airgap-ollama:latest"
  gpu_support: true
```

## Environment Variables

- `AIRAI_CONFIG` - Path to configuration file
- `OLLAMA_HOST` - Ollama server host (default: localhost:11434)
- `CONTAINER_RUNTIME` - Container runtime (podman or docker)

## Examples

### Code Generation

```bash
# Generate a Python function
airai chat qwen-32b-cline "Write a function to validate email addresses with regex"

# Generate tests
airai code test src/validators.py
```

### Code Review

```bash
# Review a file
airai code review src/app.py

# Review entire directory
airai code review src/
```

### File Editing

```bash
# Refactor code
airai code edit src/legacy.py "refactor to use modern Python 3.11 syntax"

# Add features
airai code edit src/api.py "add error handling and logging"

# Fix bugs
airai code fix src/broken.py
```

### Container Deployment

```bash
# Build container
airai container build --tag latest

# Run with GPU
airai container run --gpus all --port 11434

# Export for air-gap
airai container export --output ~/airgap-package/container.tar
```

## Architecture

```
airai/
├── cli.py              # Main CLI entry point
├── config.py           # Configuration management
├── api/
│   ├── client.py       # Ollama HTTP API client
│   ├── models.py       # Model operations
│   └── chat.py         # Chat operations
├── commands/
│   ├── server.py       # Server management
│   ├── models_cmd.py   # Model commands
│   ├── chat_cmd.py     # Chat commands
│   ├── code.py         # Code assistance (NEW)
│   ├── health.py       # Health checks
│   ├── package.py      # Air-gap packaging
│   └── container.py    # Container operations
└── utils/
    ├── console.py      # Rich console helpers
    ├── platform.py     # OS detection
    └── validators.py   # Input validation
```

## Requirements

- Python 3.9+
- Click 8.1.7+
- Rich 13.7.0+
- Requests 2.31.0+
- PyYAML 6.0.1+
- Running Ollama server (for AI features)

## Development

```bash
# Install development dependencies
pip install -e .[dev]

# Run tests
pytest

# Format code
black src/airai/
isort src/airai/

# Type checking
mypy src/airai/
```

## Troubleshooting

### Server Not Responding

```bash
# Check if Ollama is running
airai health

# Check logs
airai server logs

# Restart server
airai server restart
```

### GPU Not Detected

```bash
# Check GPU status
airai health gpu

# Verify NVIDIA drivers
nvidia-smi
```

### Connection Refused

```bash
# Check if port is open
netstat -an | grep 11434

# Test with curl
curl http://localhost:11434/api/tags
```

## Contributing

Contributions welcome! Please see the main repository for guidelines.

## License

MIT License - See LICENSE file for details.

## Support

- Documentation: https://github.com/fuzemobi/AirGapAICoder/tree/main/docs
- Issues: https://github.com/fuzemobi/AirGapAICoder/issues
- Discussions: https://github.com/fuzemobi/AirGapAICoder/discussions

## Author

**Fuzemobi, LLC**
**Chad Rosenbohm**

---

**Part of AirGapAICoder** - Enterprise air-gapped AI coding assistant
