# AirGapAICoder

> **Enterprise-grade AI coding assistant for air-gapped environments**

A complete solution for running powerful AI-assisted coding tools in secure, offline environments using open-source models and local GPU acceleration.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows%2011-blue.svg)
![GPU](https://img.shields.io/badge/GPU-NVIDIA-green.svg)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
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

## 🚀 Quick Start

### Overview

The deployment process has three phases:

1. **Preparation** (Internet-connected staging system)
2. **Transfer** (USB/removable media)
3. **Installation** (Air-gapped target server)

### Phase 1: Preparation (Requires Internet)

On an internet-connected Windows system:

```powershell
# 1. Create staging directory
New-Item -ItemType Directory -Path "C:\AirGapStaging" -Force
Set-Location C:\AirGapStaging

# 2. Download Ollama
# Visit https://ollama.com/download and save OllamaSetup.exe

# 3. Download VS Code
# Visit https://code.visualstudio.com/download and save VSCodeSetup.exe

# 4. Download NVIDIA CUDA
# Visit https://developer.nvidia.com/cuda-downloads

# 5. Install Ollama on staging system
.\OllamaSetup.exe

# 6. Download AI models (this takes time!)
ollama pull qwen2.5-coder:32b-instruct-fp16  # ~19GB
ollama pull deepseek-r1:32b                   # ~19GB
ollama pull qwen2.5-coder:14b                 # ~9GB

# 7. Download Cline extension
# Visit https://marketplace.visualstudio.com/items?itemName=saoudrizwan.claude-dev
# Click "Download Extension"

# 8. Package everything for transfer
# Follow detailed instructions in docs/INSTALLATION.md
```

### Phase 2: Transfer to Air-Gap

```powershell
# Copy the complete package to USB drive
Copy-Item -Path "C:\AirGapStaging" -Destination "E:\" -Recurse

# Total package size: ~50GB
```

### Phase 3: Server Installation

On the air-gapped target server:

```powershell
# 1. Copy package from USB to server
Copy-Item -Path "E:\AirGapStaging" -Destination "C:\AirGapInstall" -Recurse

# 2. Open PowerShell as Administrator
Set-Location C:\AirGapInstall

# 3. Run automated installation
.\scripts\install-server.ps1

# Installation completes in ~30 minutes
```

### Phase 4: Client Setup

On each developer workstation:

```powershell
# 1. Copy client files from server
# 2. Open PowerShell
Set-Location "path\to\client\files"

# 3. Run client installation
.\scripts\install-client.ps1

# 4. Enter server IP when prompted
# Example: 192.168.1.100

# Installation completes in ~5 minutes
```

### Phase 5: Start Using AI!

**From Any Terminal:**
```bash
# Check server status
./scripts/cli/ollama-cli.sh status 192.168.1.100:11434

# Generate code
./scripts/cli/ollama-cli.sh run 192.168.1.100:11434 qwen-32b-cline \
  "Write a Python FastAPI application with user authentication"
```

**Or use VS Code + Cline (Optional):**
1. **Launch VS Code**
2. **Open Cline** (click icon in sidebar or `Ctrl+Shift+P` → "Cline: Open")
3. **Start chatting with AI**

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

### Getting Started

- **[CLI Usage Guide](docs/CLI-USAGE.md)** - Use from any terminal (recommended)
- **[Client Usage Guide](docs/CLIENT-USAGE.md)** - VS Code + Cline setup (optional)
- **[Server Setup Guide](docs/SERVER-SETUP.md)** - Complete deployment guide

### Advanced

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation procedures
- **[Operations Guide](docs/OPERATIONS.md)** - Day-to-day operation and maintenance
- **[Architecture](docs/ARCHITECTURE.md)** - Technical system design
- **[Requirements](docs/REQUIREMENTS.md)** - Detailed requirements specification

### For Developers

- **[CLAUDE.md](CLAUDE.md)** - Claude Code development guidance

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
│  OMEN 35L Server (Windows 11)           │
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

### Phase 1: Core Functionality (Current)
- ✅ Basic air-gap deployment
- ✅ Multi-user support
- ✅ GPU acceleration
- ✅ VS Code integration

### Phase 2: Enhanced Management (Q2 2025)
- 🔜 Web-based admin dashboard
- 🔜 Advanced monitoring and metrics
- 🔜 Automated health checks
- 🔜 Performance analytics

### Phase 3: Advanced Features (Q3 2025)
- 🔜 Multi-GPU support
- 🔜 Load balancing across servers
- 🔜 RAG (Retrieval-Augmented Generation)
- 🔜 Custom model fine-tuning

### Phase 4: Enterprise Features (Q4 2025)
- 🔜 RBAC (Role-Based Access Control)
- 🔜 TLS/SSL encryption
- 🔜 Advanced audit logging
- 🔜 JetBrains IDE support

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

**Made with ❤️ for secure, offline AI-assisted development**

**Star ⭐ this repo if you find it useful!**
