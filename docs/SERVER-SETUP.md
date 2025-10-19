# AirGapAICoder - Server Setup Guide

**Version:** 1.0.0
**Author:** Fuzemobi, LLC - Chad Rosenbohm

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Preparation Phase (Internet-Connected)](#preparation-phase)
4. [Air-Gap Transfer](#air-gap-transfer)
5. [Server Installation](#server-installation)
6. [Service Configuration](#service-configuration)
7. [Verification](#verification)
8. [Troubleshooting](#troubleshooting)

## Overview

This guide covers the complete setup process for deploying the AirGapAICoder server in an air-gapped environment. The process has three main phases:

1. **Preparation** - Download components on internet-connected system
2. **Transfer** - Move package to air-gapped environment
3. **Installation** - Deploy and configure on target server

**Estimated Time:**
- Preparation: 2-4 hours (depending on download speed)
- Transfer: 15-30 minutes
- Installation: 30-60 minutes

## Prerequisites

### Target Server Hardware

| Component | Minimum | Recommended | Enterprise |
|-----------|---------|-------------|------------|
| **GPU** | NVIDIA RTX 3090 (24GB VRAM) | NVIDIA RTX 4090 (24GB VRAM) | NVIDIA A6000 (48GB VRAM) |
| **RAM** | 32GB DDR4 | 64GB DDR5 | 128GB DDR5 |
| **Storage** | 500GB NVMe SSD | 1TB NVMe SSD | 2TB+ NVMe SSD |
| **CPU** | 8-core modern x64 | 12-core modern x64 | 16+ core modern x64 |
| **Network** | 1 Gbps Ethernet | 2.5 Gbps Ethernet | 10 Gbps Ethernet |

### Target Server Software

- **OS**: Windows Server 2022 (or Windows 11 Pro/Enterprise)
  - Alternative: Ubuntu Server 22.04+ LTS
- **Administrator/Root Access**: Required for installation
- **Network**: Local network connectivity for client access

### Staging System (Internet-Connected)

- Windows, macOS, or Linux with internet access
- 100GB+ free disk space
- Administrator privileges
- PowerShell 5.1+ (Windows) or Bash (Unix)

### Transfer Media

- USB 3.0+ drive with 128GB+ capacity
- OR Network file share (if air-gap allows local transfers)

## Preparation Phase

Run preparation scripts on an internet-connected system to download all required components.

### Windows (PowerShell)

```powershell
# Navigate to scripts directory
cd scripts/preparation

# Run preparation script
.\pull-all.ps1

# For production models (47GB), set environment variable first:
$env:PULL_PRODUCTION_MODELS = "true"
.\pull-all.ps1
```

### Unix (macOS/Linux)

```bash
# Navigate to scripts directory
cd scripts/preparation

# Run preparation script
./pull-all.sh

# For production models (47GB), set environment variable first:
export PULL_PRODUCTION_MODELS=true
./pull-all.sh
```

### What Gets Downloaded

- **Ollama** - LLM inference engine
- **AI Models** - Qwen 2.5 Coder 32B, DeepSeek R1 32B, Qwen 14B
- **VS Code** - IDE for clients (manual download)
- **Cline Extension** - AI assistant VS Code extension
- **Configuration Files** - Modelfiles and templates

**Package Size:**
- Test mode (default): ~2GB (small test model)
- Production mode: ~50GB (full models)

## Air-Gap Transfer

### Create Transfer Package

The preparation script creates a package at:
- Windows: `C:\airgap-package`
- Unix: `~/airgap-package`

### Transfer to Air-Gap Server

**USB Transfer:**
```powershell
# Copy package to USB drive (E: in this example)
Copy-Item -Path "C:\airgap-package" -Destination "E:\" -Recurse

# On target server, copy from USB
Copy-Item -Path "E:\airgap-package" -Destination "C:\AirGapInstall" -Recurse
```

**Verification:**
```powershell
# Verify package integrity
Get-FileHash -Path "C:\AirGapInstall\airgap-package\MANIFEST.txt"

# Compare with original checksum
```

## Server Installation

### Windows Server Installation

**Open PowerShell as Administrator:**

```powershell
cd C:\AirGapInstall\scripts\installation\server

# Run installation script
.\install-windows.ps1 C:\AirGapInstall\airgap-package
```

The script will:
1. Verify prerequisites (OS version, disk space)
2. Install Ollama from package
3. Copy AI models (~47GB)
4. Configure environment variables
5. Create Windows Service
6. Configure firewall rules
7. Start and verify service

**Installation Time:** ~30 minutes (mostly model copying)

### Ubuntu Server Installation

**Open terminal with sudo access:**

```bash
cd /path/to/AirGapInstall/scripts/installation/server

# Run installation script
sudo ./install-ubuntu.sh /path/to/airgap-package
```

The script will:
1. Check Ubuntu version and dependencies
2. Install NVIDIA drivers (if needed)
3. Install Ollama
4. Copy models
5. Configure systemd service
6. Setup firewall (UFW)
7. Start and enable service

### macOS Installation (Development/Testing Only)

```bash
cd scripts/installation/server

# Run macOS installation
./install-macos.sh ~/airgap-package
```

**Note:** macOS is for development/testing only. Production deployments should use Windows Server or Ubuntu.

## Service Configuration

### Windows Service Management

```powershell
# Check service status
Get-Service -Name "Ollama"

# Start service
Start-Service -Name "Ollama"

# Stop service
Stop-Service -Name "Ollama"

# Restart service
Restart-Service -Name "Ollama"

# View service logs
Get-EventLog -LogName Application -Source "Ollama" -Newest 50
```

### Linux Service Management (Systemd)

```bash
# Check service status
systemctl status ollama

# Start service
sudo systemctl start ollama

# Stop service
sudo systemctl stop ollama

# Restart service
sudo systemctl restart ollama

# Enable on boot
sudo systemctl enable ollama

# View logs
journalctl -u ollama -f
```

### Environment Variables

**Windows (System-wide):**
```powershell
# Set environment variables
[Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0:11434", "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_NUM_PARALLEL", "1", "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_MAX_LOADED_MODELS", "1", "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_FLASH_ATTENTION", "1", "Machine")

# Restart service for changes to take effect
Restart-Service -Name "Ollama"
```

**Linux:**
```bash
# Edit service file
sudo systemctl edit ollama

# Add environment variables:
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_FLASH_ATTENTION=1"

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

## Verification

### Check Server Health

```powershell
# Test API endpoint
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"

# List available models
ollama list

# Check GPU detection (if applicable)
nvidia-smi

# Test inference
ollama run qwen-32b-cline "Write a Python function to calculate fibonacci"
```

### Network Access Verification

From a client machine on the network:

```powershell
# Get server IP
ipconfig  # Windows
ip addr   # Linux

# Test from client
$serverIP = "192.168.1.100"  # Replace with actual server IP
Invoke-RestMethod -Uri "http://${serverIP}:11434/api/tags"
```

### Firewall Configuration

**Windows:**
```powershell
# Verify firewall rule
Get-NetFirewallRule -DisplayName "Ollama"

# If rule doesn't exist, create it
New-NetFirewallRule -DisplayName "Ollama" -Direction Inbound -Port 11434 -Protocol TCP -Action Allow
```

**Ubuntu (UFW):**
```bash
# Allow port 11434
sudo ufw allow 11434/tcp

# Check status
sudo ufw status
```

## Monitoring

### Automated Monitoring

**Unix (macOS/Linux):**
```bash
# Run monitor daemon
cd scripts/services
nohup ./monitor.sh 60 &  # Check every 60 seconds

# Check monitor logs
tail -f ~/Library/Logs/airgap-monitor.log  # macOS
tail -f /var/log/airgap-monitor.log        # Linux
```

**Windows:**
```powershell
# Run monitor script
cd scripts\services
.\monitor.ps1 -CheckInterval 60

# Run as background job
Start-Job -ScriptBlock { .\scripts\services\monitor.ps1 -CheckInterval 60 }
```

### Manual Health Checks

```bash
# Use remote CLI
cd scripts/cli

# Check status
./ollama-cli.sh status 192.168.1.100:11434

# List models
./ollama-cli.sh models 192.168.1.100:11434

# Check running processes
./ollama-cli.sh ps 192.168.1.100:11434
```

## Troubleshooting

### Server Not Starting

**Check Prerequisites:**
```powershell
# Windows: Verify .NET Framework
Get-WindowsFeature NET-Framework-Core

# Verify Ollama installation
Get-Command ollama

# Check for port conflicts
netstat -ano | findstr "11434"
```

### GPU Not Detected

```powershell
# Windows: Check NVIDIA driver
nvidia-smi

# Reinstall NVIDIA driver if needed
# Run CUDA toolkit installer from package
```

**Ubuntu:**
```bash
# Check NVIDIA driver
nvidia-smi

# Install drivers if missing
sudo ubuntu-drivers autoinstall
sudo reboot
```

### Models Not Loading

```powershell
# Check models directory
ls ~/.ollama/models  # Unix
dir $env:USERPROFILE\.ollama\models  # Windows

# Re-copy models from package
cp -r /path/to/package/models/* ~/.ollama/models/
```

### Network Access Issues

```powershell
# Windows: Check firewall
Get-NetFirewallRule -DisplayName "Ollama"

# Temporarily disable to test (NOT for production)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Re-enable after testing
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

**Ubuntu:**
```bash
# Check UFW status
sudo ufw status

# Temporarily disable to test
sudo ufw disable

# Re-enable
sudo ufw enable
```

### Performance Issues

```powershell
# Check system resources
Get-Process ollama | Format-List *

# Check GPU utilization
nvidia-smi -l 1

# Set process priority to High
$process = Get-Process -Name "ollama"
$process.PriorityClass = "High"
```

## Maintenance

### Regular Tasks

- **Daily**: Monitor service health
- **Weekly**: Review logs for errors
- **Monthly**: Check disk space and model usage
- **Quarterly**: Update NVIDIA drivers (during maintenance window)

### Backup Strategy

```powershell
# Backup models
$backupDate = Get-Date -Format "yyyy-MM-dd"
Copy-Item -Path "$env:USERPROFILE\.ollama\models" `
    -Destination "E:\Backups\models-$backupDate" `
    -Recurse

# Backup configuration
# Export environment variables, firewall rules, service config
```

### Updates

For air-gap updates:
1. Run preparation script on internet-connected system to download new models
2. Transfer package to server
3. Copy new models to ~/.ollama/models
4. Restart Ollama service

## Next Steps

After server setup is complete:

1. **Configure Clients** - See [CLIENT-USAGE.md](CLIENT-USAGE.md)
2. **Setup Remote Management** - See [CLI-REFERENCE.md](../scripts/cli/README-CLI.md)
3. **Review Operations Guide** - See [OPERATIONS.md](OPERATIONS.md)

## Support

For issues or questions:
- Review [troubleshooting section](#troubleshooting)
- Check server logs
- Consult [OPERATIONS.md](OPERATIONS.md) for detailed procedures
- Open issue on GitHub: https://github.com/fuzemobi/AirGapAICoder/issues

---

**Document Version:** 1.0.0
**Last Updated:** 2025-10-19
**Author:** Fuzemobi, LLC - Chad Rosenbohm
