# Changelog

All notable changes to AirGapAICoder will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
