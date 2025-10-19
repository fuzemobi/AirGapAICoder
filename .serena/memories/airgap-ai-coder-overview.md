# AirGapAICoder Project Memory

## Project Overview
AirGapAICoder is an enterprise air-gapped AI coding assistant system for secure, network-isolated environments. It enables complete offline AI-assisted development using local LLM inference.

**Current Version**: 1.1.0-dev  
**Repository**: https://github.com/fuzemobi/AirGapAICoder  
**Author**: Fuzemobi, LLC - Chad Rosenbohm

## Core Architecture (v1.1.0)

### Technology Stack
- **Ollama Server**: GPU-accelerated LLM inference (port 11434)
- **AI Models**: 
  - Qwen 2.5 Coder 32B (19GB, primary)
  - DeepSeek R1 32B (19GB, reasoning)
  - Qwen 2.5 Coder 14B (9GB, lightweight)
- **Context Windows**: 131,072 tokens (131k)
- **GPU**: NVIDIA with CUDA acceleration
- **Platforms**: Windows Server 2022, Ubuntu 22.04+, macOS
- **New: AirAI CLI**: Python-based professional CLI tool
- **New: Container**: Podman/Docker containerization

### User Access Methods (Priority Order)
1. **AirAI CLI (NEW)**: Professional Python CLI for management and AI interaction
2. **HTTP REST API**: Accessible from ANY terminal (bash, PowerShell, zsh, curl)
3. **VS Code + Cline**: Optional IDE integration

**CRITICAL USER PREFERENCE**: CLI-first approach, no IDE dependency. Works from any terminal on any platform.

## Key User Preferences

1. **Generic Hardware References**: NEVER mention "OMEN 35L" or specific hardware. Use "GPU-accelerated server"
2. **No Docker**: Use Podman or fully open-source alternatives (licensing concerns)
3. **CLI Universal Access**: Emphasize terminal-based usage over IDE
4. **Multi-Platform**: Support Windows Server (primary), Ubuntu, macOS
5. **Semantic Versioning**: Track in VERSION file + CHANGELOG.md
6. **AI Coding Assistant**: AirAI should work like Claude Code/Cline - direct code file interaction

## New v1.1.0 Features

### AirAI CLI
Professional Python CLI tool built with Click + Rich:

**Structure:**
```
src/airai/
├── cli.py              # Main CLI entry
├── api/
│   └── client.py       # Ollama HTTP wrapper
├── commands/
│   ├── server.py       # Server management
│   ├── models_cmd.py   # Model operations
│   ├── chat_cmd.py     # AI interaction
│   ├── health.py       # Health monitoring
│   ├── package.py      # Air-gap packaging (TODO)
│   └── container.py    # Container ops (TODO)
└── utils/              # Utilities
```

**Commands:**
```bash
airai health                      # Check server
airai models list                 # List models
airai chat MODEL "prompt"         # Chat with AI
airai ask MODEL "question"        # Quick question
airai server start/stop/status    # Server management (TODO)
airai package prepare             # Air-gap packaging (TODO)
airai container build/run         # Container ops (TODO)
```

**Installation:**
```bash
pip install -e .                  # Development
python -m build                   # Build wheel
pip install dist/airai-*.whl      # Install from wheel
```

### Podman Containerization

**Containerfile Features:**
- Base: nvidia/cuda:12.2.0-runtime-ubuntu22.04
- Includes: Ollama + AirAI CLI + GPU support
- Port: 11434
- Volume: /root/.ollama/models
- Health check: Built-in

**Container Scripts:**
- `scripts/container/build.sh` - Build image
- `scripts/container/run.sh` - Run with GPU
- `scripts/container/deploy-airgap.sh` - Export for air-gap
- `scripts/container/entrypoint.sh` - Container init

**Usage:**
```bash
# Build
./scripts/container/build.sh

# Run with GPU
./scripts/container/run.sh

# Export for air-gap
./scripts/container/deploy-airgap.sh

# On air-gap system
podman load -i airgap-ollama-latest.tar
podman run -d --device nvidia.com/gpu=all -p 11434:11434 airgap-ollama:latest
```

## Project Structure (Updated)

```
AirGapAICoder/
├── src/airai/                   # NEW: AirAI CLI package
│   ├── api/                     # Ollama API client
│   ├── commands/                # CLI commands
│   └── utils/                   # Utilities
├── scripts/
│   ├── preparation/pull-all.sh  # Download components
│   ├── installation/server/     # Platform installers
│   ├── cli/ollama-cli.sh        # Legacy CLI wrapper
│   ├── services/monitor.sh      # Health monitoring
│   └── container/               # NEW: Container scripts
│       ├── build.sh
│       ├── run.sh
│       └── deploy-airgap.sh
├── config/
│   ├── modelfiles/              # Ollama extended context
│   └── cline/                   # VS Code Cline templates
├── docs/
│   ├── QUICKSTART.md            # NEW: Standalone quickstart
│   ├── CLI-USAGE.md             # Terminal usage guide
│   ├── SERVER-SETUP.md          # Deployment guide
│   ├── CLIENT-USAGE.md          # VS Code guide
│   ├── ARCHITECTURE.md          # Technical design
│   ├── REQUIREMENTS.md          # Specifications
│   ├── OPERATIONS.md            # Ops manual
│   └── INSTALLATION.md          # Detailed install
├── Containerfile                # NEW: Podman/Docker image
├── pyproject.toml               # NEW: AirAI CLI package metadata
├── README.md                    # Main entry (references QUICKSTART)
├── CHANGELOG.md                 # Release notes
├── VERSION                      # 1.1.0 (in development)
└── CLAUDE.md                    # Dev guidance
```

## Deployment Process (Updated)

### Traditional Installation (v1.0)
1. Preparation: `./scripts/preparation/pull-all.sh`
2. Transfer: USB to air-gap server (~47GB)
3. Installation: Platform-specific scripts
4. Usage: CLI wrapper or HTTP API

### Container Deployment (v1.1.0 - NEW)
1. Build: `./scripts/container/build.sh`
2. Export: `./scripts/container/deploy-airgap.sh`
3. Transfer: USB to air-gap server (container tar + models)
4. Load & Run: `./load-and-run.sh`

### AirAI CLI Deployment (v1.1.0 - NEW)
1. Build wheel: `python -m build`
2. Transfer wheel + dependencies
3. Install: `pip install airai-*.whl --no-index`
4. Use: `airai chat qwen-32b-cline "prompt"`

## Key Scripts

### Container Scripts (NEW)
- **build.sh**: Build Podman/Docker image
- **run.sh**: Run container with GPU passthrough
- **deploy-airgap.sh**: Export container tar for offline deployment

### Legacy Scripts
- **pull-all.sh**: Download components for air-gap
- **ollama-cli.sh**: Legacy HTTP API wrapper
- **monitor.sh**: Health checks with auto-restart

## Configuration

### Ollama Environment
```
OLLAMA_HOST=0.0.0.0:11434
OLLAMA_NUM_PARALLEL=1
OLLAMA_MAX_LOADED_MODELS=1
OLLAMA_FLASH_ATTENTION=1
```

### AirAI CLI Config (NEW)
Location: `~/.airai/config.yaml` (TODO: implement)
```yaml
server:
  host: localhost
  port: 11434
defaults:
  model: qwen-32b-cline
  temperature: 0.2
```

## Roadmap

### v1.0.2 (Current)
- Core platform complete
- CLI-first approach
- Comprehensive documentation
- Generic hardware references (no OMEN)

### v1.1.0 (In Development - Target Q1 2026)
- ✅ Podman containerization
- ✅ AirAI CLI foundation
- ✅ Standalone QUICKSTART.md
- ✅ Remove hardware branding
- 🔲 AI coding assistant features (like Claude Code/Cline)
- 🔲 Container model pre-loading
- 🔲 AirAI package/container commands
- 🔲 Web dashboard (planned)

### v1.2.0 (Planned Q2 2026)
- Web-based management interface
- Performance analytics
- Enhanced monitoring

### v2.0.0 (Planned Q3-Q4 2026)
- Multi-GPU support
- RAG integration
- RBAC

## AI Coding Assistant Options

**Current Status:** AirAI CLI has Ollama management features. Need to add coding assistant capabilities.

**Options:**
1. **Integrate Cline**: Use existing Cline codebase (VS Code extension) as library
2. **Build Custom**: Add file editing, context management, and agentic features to AirAI
3. **Hybrid**: AirAI manages Ollama, Cline handles coding tasks

**User Preference:** AirAI should work like Claude Code/Cline - direct file interaction and code changes.

## Important Notes for Future Development

1. **NEVER use hardware brand references** - always generic (GPU-accelerated server)
2. **CLI-first philosophy** - terminal access is primary, IDE is optional
3. **Podman over Docker** - licensing preference for air-gap environments
4. **VERSION + CHANGELOG.md** - maintain semantic versioning
5. **GitHub repo**: fuzemobi/AirGapAICoder
6. **Testing platforms**: macOS (tested), Windows/Ubuntu (scripts ready)
7. **Next priority**: Add AI coding assistant features to AirAI CLI

## Recent Changes (v1.1.0-dev)

### Completed
- Created standalone docs/QUICKSTART.md
- Removed all OMEN 35L hardware references
- Created AirAI CLI project structure (src/airai/)
- Implemented core commands: health, models list, chat
- Created Containerfile with GPU support
- Created container build/deployment scripts
- Updated README to reference QUICKSTART.md

### In Progress
- AI coding assistant features for AirAI
- Container model pre-loading
- AirAI package/container commands

### TODO
- Test container builds
- Package AirAI as wheel for air-gap distribution
- Add AI coding features (file editing, context management)
- Document container deployment in CONTAINER-DEPLOYMENT.md
- Update CHANGELOG.md for v1.1.0 release
