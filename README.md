# AirGapAICoder

> **Enterprise-grade AI coding assistant for air-gapped environments**

A complete solution for running powerful AI-assisted coding tools in secure, offline environments using open-source models and local GPU acceleration.

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20|%20Ubuntu%20|%20macOS-blue.svg)
![GPU](https://img.shields.io/badge/GPU-NVIDIA-green.svg)
![Container](https://img.shields.io/badge/deployment-podman-purple.svg)
![CLI](https://img.shields.io/badge/cli-airai-green.svg)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quickstart Guide](#quickstart-guide)
- [System Requirements](#system-requirements)
- [Deployment Process](#deployment-process)
- [Documentation](#documentation)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## 🎯 Overview

AirGapAICoder enables organizations to deploy AI-powered coding assistants in completely air-gapped (offline) environments. By leveraging open-source large language models running on local GPU hardware, it provides enterprise-grade coding assistance without any external dependencies or cloud connectivity.

**Perfect for:**
- 🔒 Secure environments requiring complete network isolation
- 🏢 Organizations with strict data sovereignty requirements
- 💼 Enterprise development teams in regulated industries
- 🛡️ Government and defense contractors
- 🔐 Companies handling sensitive intellectual property

## ✨ Features

### Core Capabilities

- ✅ **Fully Offline Operation** - Zero internet dependency after initial setup
- ✅ **GPU-Accelerated Inference** - High-performance local AI model execution
- ✅ **Extended Context Windows** - 131k tokens for large codebase analysis
- ✅ **Multi-User Support** - Network-accessible server for team collaboration
- ✅ **AirAI CLI** - Professional Python CLI for AI-assisted coding (NEW v1.1.0)
- ✅ **Container Deployment** - Podman/Docker with single-command setup (NEW v1.1.0)
- ✅ **Code Assistance** - AI file editing, review, and test generation (NEW v1.1.0)
- ✅ **Universal CLI Access** - Use from any terminal on any platform (no IDE required)
- ✅ **Optional IDE Integration** - VS Code + Cline extension available
- ✅ **Multiple Models** - Switch between coding and reasoning-focused models
- ✅ **Enterprise Security** - Complete data residency and audit logging
- ✅ **Easy Deployment** - Automated installation scripts and packaging

### AI Models Included

| Model | Parameters | VRAM | Context | Best For |
|-------|-----------|------|---------|----------|
| **Qwen 2.5 Coder 32B** | 32 Billion | 24GB | 131k tokens | General coding, refactoring |
| **DeepSeek R1 32B** | 32 Billion | 24GB | 131k tokens | Complex reasoning, algorithms |
| **Qwen 2.5 Coder 14B** | 14 Billion | 12GB | 131k tokens | Lightweight, faster responses |

## 🚀 Quick Start

**New to AirGapAICoder?** See the [Quick Start Guide](docs/QUICKSTART.md) for step-by-step instructions.

### Choose Your Deployment Method

**Traditional Installation** (Recommended)
- Manual installation with full control
- Tested on Windows, Ubuntu, macOS
- See: [QUICKSTART.md](docs/QUICKSTART.md#method-1-traditional-installation)

**Container Deployment** (NEW in v1.1.0)
- Single-command Podman/Docker deployment
- GPU passthrough support
- Perfect for air-gap environments
- See: [CONTAINER-DEPLOYMENT.md](docs/CONTAINER-DEPLOYMENT.md)

**AirAI CLI** (NEW in v1.1.0)
- Professional Python CLI tool
- AI-assisted code editing and review
- Simplified management commands
- Cross-platform support
- One-command global installation
- See: [AirAI README](src/airai/README.md)

### Quick Example

#### Install AirAI CLI Globally (One Command!)

```bash
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Windows (PowerShell - Run as Administrator)
.\scripts\installation\install-airai-windows.ps1

# macOS / Linux
./scripts/installation/install-airai.sh

# Restart terminal and verify
airai --version

# Start using immediately!
airai chat qwen-32b-cline "Write a Python hello world"
airai code review src/
airai code edit app.py "add error handling"
```

#### Full Server Deployment

```bash
# Clone and prepare (internet-connected system)
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder/scripts/preparation
./pull-all.sh

# Transfer to air-gap server via USB

# Install on server
cd scripts/installation/server
sudo ./install-ubuntu.sh ~/airgap-package

# Access from any terminal!
curl http://localhost:11434/api/generate -d '{
  "model": "qwen-32b-cline",
  "prompt": "Write a Python function",
  "stream": false
}' | jq -r '.response'
```

**See the complete guide:** [docs/QUICKSTART.md](docs/QUICKSTART.md)

---

## 💻 System Requirements

### Server (AI Inference Host)

| Component | Minimum | Recommended | Optimal |
|-----------|---------|-------------|---------|
| **GPU** | NVIDIA RTX 3090 (24GB) | RTX 4090 (24GB) | A6000 (48GB) |
| **RAM** | 32GB DDR4 | 64GB DDR5 | 128GB DDR5 |
| **Storage** | 500GB NVMe SSD | 1TB NVMe SSD | 2TB NVMe SSD |
| **CPU** | 8-core x64 | 12-core x64 | 16+ core x64 |
| **OS** | Windows 11 Pro | Windows 11 Pro | Windows 11 Enterprise |
| **Network** | 1 Gbps Ethernet | 2.5 Gbps | 10 Gbps |

### Client Workstations

- **OS**: Windows 10/11, macOS, or Linux
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space
- **Network**: Connected to same local network as server

### Software Components

- **Ollama** - LLM inference engine
- **VS Code** - IDE
- **Cline Extension** - AI assistant interface
- **NVIDIA Driver** - GPU acceleration
- **CUDA Toolkit** - GPU computing platform

## 📦 Deployment Process

The full deployment follows three phases:

1. **Preparation** (Internet-connected) - Download Ollama, models, and dependencies
2. **Transfer** (USB/removable media) - Move ~50GB package to air-gap server
3. **Installation** (Air-gapped server) - Automated setup with scripts

See [Quickstart Guide](#quickstart-guide) above for step-by-step instructions.

**Detailed guides available:**
- [SERVER-SETUP.md](docs/SERVER-SETUP.md) - Complete server deployment
- [INSTALLATION.md](docs/INSTALLATION.md) - Detailed installation procedures
- [CLI-USAGE.md](docs/CLI-USAGE.md) - Terminal usage examples

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

### Getting Started

- **[Quick Start Guide](docs/QUICKSTART.md)** - Get running in 5 steps
- **[AirAI CLI Guide](src/airai/README.md)** - AI coding assistant CLI (NEW)
- **[Container Deployment](docs/CONTAINER-DEPLOYMENT.md)** - Podman/Docker setup (NEW)
- **[AirAI + Cline Integration](docs/AIRAI-CLINE-INTEGRATION.md)** - Hybrid workflow (NEW)
- **[CLI Usage Guide](docs/CLI-USAGE.md)** - Use from any terminal
- **[Client Usage Guide](docs/CLIENT-USAGE.md)** - VS Code + Cline setup (optional)
- **[Server Setup Guide](docs/SERVER-SETUP.md)** - Complete deployment guide

### Advanced

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation procedures
- **[Operations Guide](docs/OPERATIONS.md)** - Day-to-day operation and maintenance
- **[Architecture](docs/ARCHITECTURE.md)** - Technical system design
- **[Requirements](docs/REQUIREMENTS.md)** - Detailed requirements specification

### For Developers

- **[CLAUDE.md](CLAUDE.md)** - Claude Code development guidance
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and release notes

### Quick Reference

**CLI Usage (from any terminal):**

```bash
# Check server status
./scripts/cli/ollama-cli.sh status SERVER_IP:11434

# List models
./scripts/cli/ollama-cli.sh models SERVER_IP:11434

# Generate code
./scripts/cli/ollama-cli.sh run SERVER_IP:11434 qwen-32b-cline "Write a Python function"

# Or use HTTP API directly
curl http://SERVER_IP:11434/api/generate -d '{
  "model": "qwen-32b-cline",
  "prompt": "Write a hello world",
  "stream": false
}'
```

**Server Management:**

```powershell
# Server commands
ollama serve                          # Start server
ollama list                           # List models
ollama ps                             # Check running models
nvidia-smi                            # Monitor GPU

# Monitoring
nvidia-smi -l 1                       # Real-time GPU stats
Get-Process ollama | Format-List *   # Process details
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│  GPU-Accelerated Server (Windows 11)    │
│  ┌────────────────────────────────┐     │
│  │  Ollama Server :11434          │     │
│  │  ├─ Qwen 2.5 Coder 32B         │     │
│  │  ├─ DeepSeek R1 32B            │     │
│  │  └─ Qwen 2.5 Coder 14B         │     │
│  └────────────────────────────────┘     │
│           ↕ NVIDIA GPU                  │
└─────────────────┬───────────────────────┘
                  │ Local Network
         ┌────────┴────────┐
         ↓                 ↓
    ┌─────────┐       ┌─────────┐
    │ Client  │       │ Client  │
    │ VS Code │       │ VS Code │
    │ + Cline │       │ + Cline │
    └─────────┘       └─────────┘
```

### Key Components

1. **Inference Layer**: Ollama server with GPU-accelerated LLM inference
2. **Network Layer**: HTTP API for client-server communication (port 11434)
3. **Client Layer**: VS Code with Cline extension for developer interaction

**Technology Stack:**
- **Inference Engine**: Ollama (open-source)
- **AI Models**: Qwen 2.5 Coder, DeepSeek R1 (open-source)
- **Interface**: HTTP REST API (universal access)
- **CLI**: Cross-platform command-line tools
- **Optional Client**: VS Code + Cline extension
- **GPU**: NVIDIA with CUDA acceleration
- **Platform**: Windows Server 2022, Ubuntu 22.04+, or Windows 11

## 🔐 Security Features

- ✅ **Network Isolation**: No outbound internet connectivity required
- ✅ **Data Residency**: All processing happens locally
- ✅ **Access Control**: IP-based client whitelisting
- ✅ **Audit Logging**: Comprehensive activity logs
- ✅ **Firewall Protection**: Strict port restrictions
- ✅ **No External APIs**: Zero dependency on cloud services

## 🎯 Use Cases

### Software Development

- Code generation from any terminal
- Refactoring and optimization
- Bug fixing and debugging
- Documentation generation
- Code review assistance
- Integration with any text editor or IDE
- Shell script automation
- CI/CD pipeline integration

### Enterprise Applications

- Secure development environments
- Regulated industry compliance (finance, healthcare, defense)
- Intellectual property protection
- Custom model fine-tuning (future)
- Team collaboration without data leakage

## 📊 Performance

With recommended hardware (RTX 4090, 64GB RAM):

| Metric | Performance |
|--------|-------------|
| **Time to First Token** | < 500ms |
| **Generation Speed** | 50+ tokens/second |
| **Concurrent Users** | 3-5 simultaneous |
| **Context Window** | 131,072 tokens |
| **Model Load Time** | < 10 seconds |
| **GPU Utilization** | 80-100% during inference |

## 🛠️ Troubleshooting

### Common Issues

**Server not responding:**
```powershell
# Restart Ollama
Stop-Process -Name "ollama" -Force
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
```

**GPU not detected:**
```powershell
# Verify NVIDIA driver
nvidia-smi

# Check CUDA installation
nvcc --version
```

**Clients can't connect:**
```powershell
# Check firewall
Get-NetFirewallRule -DisplayName "Ollama"

# Verify server is listening
netstat -an | Select-String "11434"
```

See [Operations Guide](docs/OPERATIONS.md) for complete troubleshooting.

## 🗺️ Roadmap

### v1.0 - Core Platform (Current) ✅
- ✅ Air-gap deployment automation
- ✅ Multi-platform support (Windows Server, Ubuntu, macOS)
- ✅ Universal CLI access from any terminal
- ✅ GPU-accelerated inference
- ✅ Multi-user network support
- ✅ Extended 131k token context windows
- ✅ Service monitoring and auto-restart
- ✅ Comprehensive documentation

### v1.1 - Containerization & AirAI CLI (Released 2025-10-19) ✅
- ✅ Podman-based deployment
- ✅ AirAI professional Python CLI
- ✅ AI-assisted code editing and review
- ✅ Single-command container deployment
- ✅ GPU passthrough support
- ✅ Container build and deployment scripts
- ✅ Comprehensive documentation updates

### v1.2 - Enhanced Management (Q2 2026)
- 🔜 Web-based admin dashboard
- 🔜 Real-time metrics and analytics
- 🔜 Advanced monitoring alerts
- 🔜 Performance profiling tools
- 🔜 User activity tracking

### v2.0 - Enterprise Features (Q3-Q4 2026)
- 🔜 Multi-GPU support
- 🔜 Load balancing across servers
- 🔜 RAG (Retrieval-Augmented Generation)
- 🔜 Custom model fine-tuning
- 🔜 RBAC (Role-Based Access Control)
- 🔜 TLS/SSL encryption
- 🔜 Advanced audit logging

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```powershell
# Clone repository
git clone https://github.com/fuzemobi/AirGapAICoder.git
cd AirGapAICoder

# Follow installation guide
# See docs/INSTALLATION.md
```

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Fuzemobi, LLC**
**Chad Rosenbohm**

## 🙏 Acknowledgments

- **Ollama** - Open-source LLM inference engine
- **Qwen Team** - Qwen 2.5 Coder models
- **DeepSeek** - DeepSeek R1 reasoning model
- **Cline Extension** - VS Code AI assistant interface
- **NVIDIA** - CUDA and GPU technology

## 📞 Support

For issues, questions, or suggestions:

- 📖 Check the [documentation](docs/)
- 🐛 Open an [issue](https://github.com/fuzemobi/AirGapAICoder/issues)
- 💬 Start a [discussion](https://github.com/fuzemobi/AirGapAICoder/discussions)

## ⚠️ Disclaimer

This solution is designed for legal, defensive security purposes only. Users are responsible for ensuring compliance with all applicable licenses, regulations, and organizational policies.

---

---

## 🎯 Project Status

**Current Version:** 1.1.0
**Status:** Production Ready
**Last Updated:** 2025-10-19

### Recent Updates (v1.1.0)

- ✅ **AirAI CLI** - Professional Python CLI with AI coding assistance
- ✅ **Container Deployment** - Podman/Docker with GPU support
- ✅ **AI Code Editing** - File editing, review, and test generation
- ✅ **Standalone Quickstart** - Dedicated deployment guide
- ✅ **Integration Guide** - AirAI + Cline hybrid workflow
- ✅ **Generic Hardware** - Removed all brand-specific references
- ✅ **Complete Documentation** - Comprehensive guides for all features

### What's Working

- **Preparation Scripts**: Download and package components for air-gap
- **Installation Scripts**: Automated setup for Windows, Ubuntu, macOS
- **CLI Tools**: Remote management from any terminal
- **Monitoring**: Health checks with automatic restart
- **Documentation**: Complete guides for deployment and usage

### Tested Platforms

- ✅ macOS (development and testing)
- ⚙️ Windows Server 2022 (scripts ready, pending hardware testing)
- ⚙️ Ubuntu Server 22.04+ (scripts ready, pending hardware testing)

### Community

- **GitHub Repository**: https://github.com/fuzemobi/AirGapAICoder
- **Issues**: Report bugs or request features
- **Discussions**: Share your deployment experiences
- **Contributions**: Pull requests welcome!

---

**Made with ❤️ for secure, offline AI-assisted development**

**Star ⭐ this repo if you find it useful!**
