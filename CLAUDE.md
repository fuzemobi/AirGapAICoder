# CLAUDE.md

Hey, just some notes for working on this codebase.

## How I organize things

So I've got this two-level approach going on. There's my global `~/.claude/CLAUDE.md` that has the usual stuff - code quality, security basics (OWASP and whatnot), git workflows, testing standards, that kind of thing. It applies to everything I work on.

Then for this specific project, check out `PROJECT_STANDARDS.md` - that's where the AirGapAICoder-specific stuff lives. Things like thinking through changes from different angles (architecture, development, security, QA), how to classify changes, and the air-gap deployment considerations.

## Working on this project

Before you start making changes, take a look at `PROJECT_STANDARDS.md` to understand the workflows. It covers how to handle different types of changes and what needs to be updated.

When you're making changes, think about them from a few perspectives - architecture, development, security, and testing. Keep `docs/ARCHITECTURE.md` and `README.md` up to date if your changes affect them. Do a quick security review on code changes. And yeah, commit and push your tested changes.

Check `PROJECT_STANDARDS.md` for the details on all this.

---

## What this is

This is basically an AI coding assistant that runs completely offline - perfect for air-gapped/secure environments where you can't hit external APIs. Uses local LLM inference on a GPU-accelerated server that developers can access over the local network.

## How it's set up

The main components:

- Ollama Server running on Windows 11 with an NVIDIA GPU, listening on 0.0.0.0:11434 so the network can reach it. Manages the LLMs.

- AI Models I'm using:
  - Qwen 2.5 Coder 32B (19GB) - main workhorse, 131k context
  - DeepSeek R1 32B (19GB) - for more complex reasoning
  - Qwen 2.5 Coder 14B (9GB) - lighter backup option

- Client side is Cline (VS Code extension) that talks to Ollama over HTTP. Multiple users can connect at once.

- Also need CUDA toolkit for GPU stuff, plus some PowerShell scripts to deploy and manage everything, basic monitoring.

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

## Hardware you'll need

Server side:
- NVIDIA GPU with at least 24GB VRAM (32GB+ is better for the 32B models)
- 32GB+ system RAM
- 100GB+ free disk space for models and cache
- Windows 11 Pro
- Gigabit ethernet

Client machines:
- 8GB+ RAM (for VS Code)
- 1GB+ storage (VS Code + Cline)
- Gigabit network connection to server

## Important config stuff

For Ollama models, I'm using custom Modelfiles with extended context:

```
PARAMETER num_ctx 131072        # 131k token context window
PARAMETER temperature 0.2       # Low temperature for code generation
PARAMETER num_gpu 1             # Force GPU usage
```

Ollama environment variables (Windows):
- `OLLAMA_HOST=0.0.0.0:11434` - lets network reach it
- `OLLAMA_NUM_PARALLEL=1` - run one model at a time for best performance
- `OLLAMA_MAX_LOADED_MODELS=1` - keeps VRAM usage optimized
- `OLLAMA_FLASH_ATTENTION=1` - speed boost

Cline needs to be pointed at the server:
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

## Useful commands

Server stuff (PowerShell as admin):

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

Model stuff:

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

Firewall:

```powershell
# Enable Ollama network access
New-NetFirewallRule -DisplayName "Ollama" -Direction Inbound -Port 11434 -Protocol TCP -Action Allow

# Check firewall rule
Get-NetFirewallRule -DisplayName "Ollama"
```

Monitoring performance:

```powershell
# GPU utilization
nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv -l 1

# Process memory usage
Get-Process ollama | Select-Object Name, CPU, @{Name="Memory(GB)";Expression={[math]::Round($_.WS / 1GB, 2)}}

# Set high priority for Ollama
$process = Get-Process -Name "ollama"
$process.PriorityClass = "High"
```

## Getting this into an air-gapped environment

Step 1 - Prep on a machine with internet:

Download everything you need:
- Ollama installer for Windows
- VS Code installer (System mode)
- Cline extension (.vsix file)
- NVIDIA CUDA Toolkit
- Git for Windows if you want it

Pull and configure the models:
```powershell
ollama pull qwen2.5-coder:32b-instruct-fp16
ollama pull deepseek-r1:32b
ollama pull qwen2.5-coder:14b

# Create custom models with extended context
ollama create qwen-32b-cline -f Modelfile-qwen32b
ollama create deepseek-r1-32b-cline -f Modelfile-deepseek32b
```

Package it all up:
```powershell
# Models are in: %USERPROFILE%\.ollama\models
# Copy the whole .ollama directory
# You're looking at ~47GB total for all models
```

Step 2 - Install on the air-gapped server:

1. Transfer everything via USB
2. Run scripts/install-airgap.ps1
3. Set up firewall and environment variables
4. Check GPU with nvidia-smi
5. Test with ollama run

Step 3 - Set up clients:

1. Install VS Code on workstations
2. Install Cline from the .vsix file
3. Point Cline to the server IP
4. Test it out

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

## Security stuff to think about

- Keep the server on an isolated VLAN with no internet
- Use Windows auth for Ollama access
- Lock down firewall - only allow port 11434 from known client IPs
- Verify checksums on downloaded models before deploying
- Turn on logging for audit trails

## Making it faster

GPU tips:
- Use fp16 models - way better VRAM efficiency
- Enable flash attention for speed
- Watch GPU temps and throttling
- Keep NVIDIA drivers updated

System tweaks:
- Windows power plan to "High Performance"
- Kill unnecessary Windows services
- Bump Ollama process priority to High
- Put models on an SSD

Picking models based on your VRAM:

| VRAM | Recommended Model | Context | Performance |
|------|------------------|---------|-------------|
| 24GB | Qwen 2.5 Coder 32B | 131k | Excellent |
| 32GB | Qwen 2.5 Coder 32B + DeepSeek R1 | 131k | Optimal |
| 48GB+ | Qwen 2.5 Coder 72B | 131k+ | Maximum |

## When things go wrong

Ollama not using GPU:
```powershell
# Verify CUDA installation
nvidia-smi
# Check Ollama process GPU usage
nvidia-smi pmon
```

Network connection refused:
```powershell
# Check Ollama is listening on network
netstat -an | Select-String "11434"
# Verify firewall rule
Get-NetFirewallRule -DisplayName "Ollama"
```

Slow inference:
```powershell
# Check GPU utilization
nvidia-smi
# Verify model is loaded on GPU
ollama ps
# Check system resources
Get-Process ollama | Format-List *
```

## Testing it

```powershell
# Test server health
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"

# Test model inference
ollama run qwen-32b-cline "def fibonacci(n):"

# Test network access from client
Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/tags"

# Quick performance check
Measure-Command { ollama run qwen-32b-cline "Write a sorting algorithm" }
```

## Keeping it running

Regular stuff to check:
- Disk space (model cache grows over time)
- Logs for errors or weirdness
- NVIDIA driver updates when you can
- Model integrity checks now and then

Where to find logs:
- Ollama: `%LOCALAPPDATA%\Ollama\logs`
- Windows Event Viewer
- Custom logs in `logs/` directory

## Ideas for later

- Web-based admin interface
- Smart model switching based on what you're doing
- Multi-GPU support for running models in parallel
- Usage metrics dashboard
- Automated backups
