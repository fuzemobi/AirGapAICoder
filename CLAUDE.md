# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 📋 Standards Hierarchy

This project follows a **two-tier standards system**:

### 1. Global Standards (Applies to ALL Your Projects)
**Location:** `~/.claude/CLAUDE.md`

Universal development standards that apply to every project:
- Code quality and best practices
- Security standards (OWASP Top 10, input validation)
- Git workflow (mandatory commit-and-push)
- Documentation requirements
- Testing standards
- Language-specific best practices

**These are automatically loaded for every project you work on.**

### 2. Project-Specific Standards (AirGapAICoder)
**Location:** `PROJECT_STANDARDS.md` (this repository)

AirGapAICoder-specific requirements that **extend and override** global standards:
- Multi-persona approach (Architect, Developer, Security, QA)
- Change classification system (Significant vs. Trivial)
- Air-gap deployment considerations
- Project-specific workflows and checklists

---

## ⚠️ MANDATORY: Project Standards

**YOU MUST read and strictly follow ALL standards defined in `PROJECT_STANDARDS.md` before starting any work.**

**At the beginning of EVERY session:**
1. ✅ Apply **global standards** from `~/.claude/CLAUDE.md` (automatic)
2. ✅ Read `PROJECT_STANDARDS.md` in its entirety
3. ✅ Understand the mandatory workflows for Significant vs. Trivial changes
4. ✅ Apply all Universal Rules to EVERY change
5. ✅ Update `docs/ARCHITECTURE.md` and `README.md` as required
6. ✅ Complete security reviews for all code changes
7. ✅ **Commit and push** all tested changes (global standard)

**You are required to act as ALL of the following simultaneously:**
- Software Architect
- Lead Developer
- Security Architect
- QA Engineer

**See `PROJECT_STANDARDS.md` for complete requirements.**

---

## Project Purpose

AirGapAICoder is an enterprise air-gapped AI coding assistant system that runs completely offline using local LLM inference. The system provides AI-assisted development capabilities in secure, network-isolated environments.

**Target Deployment**: GPU-accelerated server, accessible via local network to multiple developer workstations.

## System Architecture

### Core Components Stack

1. **Ollama Server** (GPU-accelerated inference engine)
   - Runs on Windows 11 host with NVIDIA GPU
   - Configured for network accessibility (0.0.0.0:11434)
   - Manages multiple large language models

2. **Primary AI Models**
   - **Qwen 2.5 Coder 32B** (19GB) - Main coding assistant with 131k context
   - **DeepSeek R1 32B** (19GB) - Advanced reasoning and problem-solving
   - **Qwen 2.5 Coder 14B** (9GB) - Backup/lightweight option

3. **Client Interface**
   - **Cline** - VS Code extension for AI-assisted development
   - Connects to Ollama server via HTTP API
   - Supports multiple concurrent users on network

4. **Supporting Infrastructure**
   - CUDA toolkit for GPU acceleration
   - PowerShell scripts for deployment and management
   - Monitoring and logging systems

### Network Architecture

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

## Hardware Requirements

### Server (GPU-Accelerated)
- **GPU**: NVIDIA with 24GB+ VRAM (32GB+ recommended for 32B models)
- **RAM**: 32GB+ system RAM
- **Storage**: 100GB+ free space for models and cache
- **OS**: Windows 11 Professional
- **Network**: Gigabit Ethernet for local network access

### Client Workstations
- **RAM**: 8GB+ (VS Code + extensions)
- **Storage**: 1GB+ for VS Code and Cline extension
- **Network**: Gigabit Ethernet connection to server

## Key Configuration Parameters

### Ollama Model Configuration

All models use extended context windows via custom Modelfiles:

```
PARAMETER num_ctx 131072        # 131k token context window
PARAMETER temperature 0.2       # Low temperature for code generation
PARAMETER num_gpu 1             # Force GPU usage
```

### Environment Variables (Windows)

Critical Ollama configuration:
- `OLLAMA_HOST=0.0.0.0:11434` - Enable network access
- `OLLAMA_NUM_PARALLEL=1` - Single model at a time for max performance
- `OLLAMA_MAX_LOADED_MODELS=1` - Optimize VRAM usage
- `OLLAMA_FLASH_ATTENTION=1` - Enable flash attention for speed

### Cline Configuration

Client configuration for network access:
```json
{
  "apiModelOverride": {
    "modelId": "qwen-32b-cline",
    "apiProvider": "ollama",
    "baseUrl": "http://SERVER_IP:11434"
  },
  "customModelOverride": [{
    "id": "qwen-32b-cline",
    "contextWindow": 131072,
    "maxTokens": 8192,
    "supportsComputerUse": true
  }]
}
```

## Development Commands

### Server Management (Windows PowerShell - Run as Administrator)

```powershell
# Start Ollama server
ollama serve

# Start Ollama in background
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden

# Check running models
ollama ps

# List available models
ollama list

# Test a model
ollama run qwen-32b-cline "Write a Python function"

# Monitor GPU usage
nvidia-smi -l 1

# Check Ollama process
Get-Process -Name "ollama"

# View server status
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"
```

### Model Management

```powershell
# Pull new models (requires internet - staging environment only)
ollama pull qwen2.5-coder:32b-instruct-fp16

# Create custom model with extended context
ollama create qwen-32b-cline -f .\Modelfile-qwen32b

# Remove unused models
ollama rm model-name

# Show model details
ollama show qwen-32b-cline
```

### Firewall Configuration

```powershell
# Enable Ollama network access
New-NetFirewallRule -DisplayName "Ollama" -Direction Inbound -Port 11434 -Protocol TCP -Action Allow

# Check firewall rule
Get-NetFirewallRule -DisplayName "Ollama"
```

### Performance Monitoring

```powershell
# GPU utilization
nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv -l 1

# Process memory usage
Get-Process ollama | Select-Object Name, CPU, @{Name="Memory(GB)";Expression={[math]::Round($_.WS / 1GB, 2)}}

# Set high priority for Ollama
$process = Get-Process -Name "ollama"
$process.PriorityClass = "High"
```

## Air-Gap Deployment Process

### Phase 1: Preparation (Internet-Connected Staging System)

1. **Download software packages**:
   - Ollama for Windows installer
   - VS Code installer (System mode)
   - Cline extension (.vsix file)
   - NVIDIA CUDA Toolkit
   - Git for Windows (optional)

2. **Download and configure models**:
   ```powershell
   ollama pull qwen2.5-coder:32b-instruct-fp16
   ollama pull deepseek-r1:32b
   ollama pull qwen2.5-coder:14b

   # Create custom models with extended context
   ollama create qwen-32b-cline -f Modelfile-qwen32b
   ollama create deepseek-r1-32b-cline -f Modelfile-deepseek32b
   ```

3. **Package for transfer**:
   ```powershell
   # Models stored in: %USERPROFILE%\.ollama\models
   # Copy entire .ollama directory
   # Total size: ~47GB for all models
   ```

### Phase 2: Air-Gap Installation (Target Server)

1. **Transfer files** via USB/removable media
2. **Run installation script** (scripts/install-airgap.ps1)
3. **Configure network access** (firewall, environment variables)
4. **Verify GPU acceleration** (nvidia-smi)
5. **Test model inference** (ollama run)

### Phase 3: Client Setup

1. **Install VS Code** on client workstations
2. **Install Cline extension** from .vsix file
3. **Configure Cline** to point to server IP
4. **Test connection** and inference

## Project Structure

```
AirGapAICoder/
├── src/                      # Python utilities and automation
│   ├── server/              # Server management utilities
│   ├── monitoring/          # Performance monitoring tools
│   └── deployment/          # Deployment automation
├── scripts/                  # PowerShell deployment scripts
│   ├── install-airgap.ps1   # Main installation script
│   ├── configure-server.ps1 # Server configuration
│   ├── create-package.ps1   # Package models for transfer
│   └── verify-setup.ps1     # Post-installation validation
├── config/                   # Configuration files
│   ├── modelfiles/          # Ollama Modelfile definitions
│   └── cline/               # Cline configuration templates
├── docs/                     # Documentation
│   ├── REQUIREMENTS.md      # Detailed requirements
│   ├── ARCHITECTURE.md      # System architecture
│   ├── INSTALLATION.md      # Installation guide
│   └── OPERATIONS.md        # Operations manual
└── tests/                    # Testing utilities
```

## Security Considerations

1. **Network Isolation**: Server should be on isolated VLAN with no internet access
2. **Access Control**: Use Windows authentication for Ollama access
3. **Firewall Rules**: Only allow port 11434 from trusted client IPs
4. **Model Integrity**: Verify checksums of downloaded models
5. **Logging**: Enable comprehensive logging for audit trails

## Performance Optimization

### GPU Optimization
- Use fp16 models for better VRAM efficiency
- Enable flash attention for faster inference
- Monitor GPU temperature and throttling
- Ensure latest NVIDIA drivers installed

### System Optimization
- Set Windows power plan to "High Performance"
- Disable unnecessary Windows services
- Set Ollama process priority to High
- Use SSD for model storage

### Model Selection by VRAM

| VRAM | Recommended Model | Context | Performance |
|------|------------------|---------|-------------|
| 24GB | Qwen 2.5 Coder 32B | 131k | Excellent |
| 32GB | Qwen 2.5 Coder 32B + DeepSeek R1 | 131k | Optimal |
| 48GB+ | Qwen 2.5 Coder 72B | 131k+ | Maximum |

## Troubleshooting

### Common Issues

**Ollama not using GPU**:
```powershell
# Verify CUDA installation
nvidia-smi
# Check Ollama process GPU usage
nvidia-smi pmon
```

**Network connection refused**:
```powershell
# Check Ollama is listening on network
netstat -an | Select-String "11434"
# Verify firewall rule
Get-NetFirewallRule -DisplayName "Ollama"
```

**Slow inference**:
```powershell
# Check GPU utilization
nvidia-smi
# Verify model is loaded on GPU
ollama ps
# Check system resources
Get-Process ollama | Format-List *
```

## Testing

```powershell
# Test server health
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"

# Test model inference
ollama run qwen-32b-cline "def fibonacci(n):"

# Test network access from client
Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/tags"

# Performance benchmark
Measure-Command { ollama run qwen-32b-cline "Write a sorting algorithm" }
```

## Maintenance

### Regular Tasks
- Monitor disk space (model cache can grow)
- Review logs for errors or performance issues
- Update NVIDIA drivers during maintenance windows
- Verify model integrity periodically

### Log Locations
- Ollama logs: `%LOCALAPPDATA%\Ollama\logs`
- Windows Event Viewer: Application logs
- Custom monitoring logs: `logs/` directory

## Future Enhancements

- Web-based management interface
- Automated model switching based on task
- Multi-GPU support for parallel inference
- Metrics dashboard for usage analytics
- Automated backup and restore procedures
