# Changelog

All notable changes to AirGapAICoder will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - One-Command Global Installation

#### Automated Installation Scripts
- **install-airai-windows.ps1** - PowerShell installer for Windows
  - Checks for Python 3.9+ installation
  - Ensures pip is available
  - Installs AirAI CLI globally
  - Verifies command availability
  - Beautiful colored output with status messages
  - Supports wheel-based air-gap installation
- **install-airai.sh** - Bash installer for macOS/Linux
  - Cross-platform Python version detection
  - macOS Homebrew Python support (--break-system-packages)
  - Automatic PATH configuration hints
  - Air-gap deployment support
  - Beautiful terminal output with colors
- **uninstall-airai-windows.ps1** - PowerShell uninstaller
- **uninstall-airai.sh** - Bash uninstaller

#### Key Features
- ✅ **One-command installation** - No manual pip/Python management
- ✅ **Platform detection** - Handles macOS, Linux, Windows differences
- ✅ **Python 3.9+ validation** - Clear error messages if not met
- ✅ **pip bootstrapping** - Auto-installs pip if missing
- ✅ **PATH verification** - Tests that `airai` command is accessible
- ✅ **Air-gap support** - Install from wheel files offline
- ✅ **Helpful guidance** - Clear next steps after installation

#### Documentation Updates
- Updated `src/airai/README.md` with Quick Install section
- Updated main `README.md` with one-command installation example
- Added installation examples to Quick Start section
- Added uninstall instructions

### Technical Details

**Script Capabilities:**
- Automatic Python version parsing (compatible with GNU and BSD tools)
- macOS externally-managed environment handling
- Clear error messages and troubleshooting hints
- Success verification with version output
- Executable permissions set automatically (Unix)

**Installation Methods:**
1. **Development Install**: `pip install -e .` from source
2. **Air-Gap Install**: From wheel file with `--no-index`
3. **User Install**: `--user` flag for non-sudo (Windows)
4. **System Install**: `--break-system-packages` for macOS Homebrew

### Changed
- Enhanced `pyproject.toml` console script entry point (`airai = "airai.cli:main"`)
- Improved installation documentation across all READMEs

### Benefits
- **Developer Experience**: Get started in 30 seconds instead of manual setup
- **Enterprise Deployment**: Scriptable installation for IT automation
- **Offline Support**: Works in air-gapped environments with wheels
- **Cross-Platform**: Identical experience on Windows, macOS, Linux

---

## [1.1.0] - 2025-10-19

### 🎉 Major Release - Containerization & AirAI CLI

This release introduces two major features: **Podman containerization** for simplified deployment and **AirAI CLI** - a professional command-line tool for managing and interacting with AI coding assistants.

### Added

#### AirAI CLI - Professional Command-Line Tool
- **New Python CLI application** built with Click and Rich
- Beautiful terminal output with colored text, tables, and progress indicators
- Cross-platform support (Windows, macOS, Linux)
- Commands:
  - `airai health` - Check Ollama server health
  - `airai models list` - List available AI models
  - `airai chat MODEL "prompt"` - Chat with AI models
  - `airai ask MODEL "question"` - Quick questions (alias)
  - `airai code edit FILE` - AI-assisted file editing (NEW)
  - `airai code review PATH` - Code review with AI (NEW)
  - `airai code fix FILE` - AI-guided bug fixes (NEW)
  - `airai code test FILE` - Generate tests with AI (NEW)
  - `airai server start/stop/status` - Server management
  - `airai package prepare` - Air-gap packaging
  - `airai container build/run` - Container operations
- Installable via pip: `pip install -e .` or from wheel
- Configuration management via YAML
- Air-gap friendly packaging

#### Podman Containerization
- **Containerfile** with GPU support (nvidia/cuda base)
- Single-command deployment for air-gap environments
- Container scripts:
  - `scripts/container/build.sh` - Build container image
  - `scripts/container/run.sh` - Run with GPU passthrough
  - `scripts/container/deploy-airgap.sh` - Export for offline deployment
- GPU passthrough support (`--device nvidia.com/gpu=all`)
- Model persistence via volumes
- Built-in health checks
- Air-gap export/import workflow

#### Documentation
- **Standalone Quickstart Guide** (docs/QUICKSTART.md)
  - Step-by-step deployment instructions
  - Three deployment methods: Traditional, Container, AirAI CLI
  - Platform-specific examples
  - Quick usage examples
- **Container Deployment Guide** (docs/CONTAINER-DEPLOYMENT.md)
- **AirAI CLI Documentation** (src/airai/README.md)
- **AirAI + Cline Integration Guide** (docs/AIRAI-CLINE-INTEGRATION.md)
- Updated README with references to new guides

#### Project Infrastructure
- `pyproject.toml` - Modern Python packaging
- Professional project structure in `src/airai/`
- Comprehensive API client for Ollama HTTP API
- Cross-platform utilities and helpers

### Changed

#### Removed Hardware Branding
- Removed all "OMEN 35L" references from documentation
- Updated to generic "GPU-Accelerated Server" terminology
- Applies to: README, CLAUDE.md, INSTALLATION.md, REQUIREMENTS.md

#### Documentation Reorganization
- README now references standalone QUICKSTART.md
- Streamlined main README for better overview
- Separated deployment methods for clarity
- Enhanced navigation and discoverability

### Technical Details

**AirAI CLI Stack:**
- Click 8.1.7 - CLI framework
- Rich 13.7.0 - Terminal formatting
- Requests 2.31.0 - HTTP client
- PyYAML 6.0.1 - Configuration
- Python 3.9+ required

**Container Stack:**
- Base: nvidia/cuda:12.2.0-runtime-ubuntu22.04
- Ollama server with GPU acceleration
- AirAI CLI pre-installed
- Port 11434 exposed
- Volume: /root/.ollama/models

**File Changes:**
- Added: `Containerfile`, `pyproject.toml`, `src/airai/` directory
- Added: `scripts/container/` scripts
- Added: `docs/QUICKSTART.md`, `docs/CONTAINER-DEPLOYMENT.md`
- Updated: `VERSION`, `README.md`, `CLAUDE.md`, documentation files

### Migration Notes

**For Existing Users:**
- Traditional installation still fully supported
- No breaking changes to existing deployments
- New features are additive

**Try the New Features:**
```bash
# Install AirAI CLI
pip install -e .

# Try container deployment
./scripts/container/build.sh
./scripts/container/run.sh

# Use AirAI CLI
airai health
airai models list
airai chat qwen-32b-cline "Write a function"
```

### Known Limitations

- Container GPU support requires nvidia-container-toolkit
- Windows container deployment requires WSL2 or Docker Desktop
- AirAI coding assistant features are MVP (file editing, review)
- Some advanced features still in development

### Next Steps (v1.2.0)

- Enhanced AI coding assistant features
- Web-based administration dashboard
- Advanced monitoring and analytics
- Multi-GPU support planning

---

## [1.0.2] - 2025-10-19

### Added
- **Comprehensive Quickstart Guide** in README.md
  - 5-step process from zero to AI coding
  - Platform-specific installation commands
  - Quick examples for code generation, review, refactoring, documentation
  - Python, curl, and PowerShell usage examples
- **Project Status Section** in README
  - Current version and testing status
  - Recent updates summary
  - Platform testing status
  - Community links
- **Enhanced Roadmap** with version-specific milestones
  - v1.0 (Current) - Core platform features
  - v1.1 (Q1 2026) - Containerization with Podman
  - v1.2 (Q2 2026) - Web-based management
  - v2.0 (Q3-Q4 2026) - Enterprise features

### Changed
- Reorganized README for better flow and discoverability
- Simplified deployment process description
- Updated table of contents with Quickstart Guide
- Enhanced roadmap with clearer timelines and deliverables

---

## [1.0.1] - 2025-10-19

### Changed
- **Emphasized universal CLI access** - No IDE required
- Repositioned CLI as primary interface (VS Code + Cline now optional)
- Updated README to highlight terminal-first approach

### Added
- **Comprehensive CLI Usage Guide** (docs/CLI-USAGE.md)
  - Usage from any terminal (bash, PowerShell, zsh, etc.)
  - Direct HTTP API examples with curl, wget
  - Integration examples: Python, Node.js, Vim, Emacs
  - Git hooks, Makefile, CI/CD integration
  - Batch operations and automation examples
- Documentation emphasizes platform-agnostic access

### Key Message
**AirGapAICoder works from ANY terminal on ANY platform - no specific IDE required**

---

## [1.0.0] - 2025-10-19

### Added
- Initial release of AirGapAICoder
- Complete air-gap deployment solution for AI coding assistants
- Multi-platform support (Windows 11, Ubuntu 22.04+, macOS)
- Comprehensive documentation suite:
  - Installation guide (INSTALLATION.md)
  - Architecture documentation (ARCHITECTURE.md)
  - Requirements specification (REQUIREMENTS.md)
  - Operations manual (OPERATIONS.md)
- Configuration templates:
  - Ollama Modelfiles for extended context (131k tokens)
  - Cline extension settings
- Support for multiple AI models:
  - Qwen 2.5 Coder 32B (primary)
  - DeepSeek R1 32B (reasoning)
  - Qwen 2.5 Coder 14B (lightweight)
- Automated deployment scripts:
  - Preparation scripts for air-gap packaging (pull-all.sh/ps1)
  - Server installation scripts (Windows, Ubuntu, macOS)
  - Client installation scripts (cross-platform)
  - Service management and monitoring
  - Remote CLI wrapper for management
  - Health check and maintenance scripts
- GPU acceleration with NVIDIA CUDA
- Extended context windows (131k tokens)
- Multi-user network access capability
- Enterprise security features
- MIT License

### Author
Fuzemobi, LLC - Chad Rosenbohm

### Repository
https://github.com/fuzemobi/AirGapAICoder

---

## Planned Features

### [1.1.0] - Planned (Q1 2026)

#### Containerization Support
- **Podman-based deployment** for easy containerized setup
- Support for Windows Server and high-performance Linux distributions
- Optimized for AMD Ryzen 7 processors
- Pre-built container images with all dependencies
- Simplified deployment and updates
- Container orchestration scripts

#### Additional Enhancements
- Web-based administration dashboard
- Enhanced monitoring and metrics
- Automated health checks
- Performance analytics and reporting

---

## Version Numbering

- **Major**: Breaking changes or significant architectural updates
- **Minor**: New features, backward-compatible
- **Patch**: Bug fixes, documentation updates, minor improvements
