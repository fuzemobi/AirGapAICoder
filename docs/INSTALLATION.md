# AirGapAICoder - Installation Guide

## Document Information

- **Version**: 1.0
- **Date**: 2025-10-19
- **Audience**: System Administrators, DevOps Engineers

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Phase 1: Preparation (Internet-Connected)](#2-phase-1-preparation-internet-connected)
3. [Phase 2: Transfer to Air-Gap](#3-phase-2-transfer-to-air-gap)
4. [Phase 3: Server Installation](#4-phase-3-server-installation)
5. [Phase 4: Client Setup](#5-phase-4-client-setup)
6. [Phase 5: Verification](#6-phase-5-verification)
7. [Troubleshooting](#7-troubleshooting)

## 1. Prerequisites

### 1.1 Staging System (Internet-Connected)

Required for initial downloads and package preparation:

- **OS**: Windows 10/11 (matching target system preferred)
- **Internet**: Broadband connection (50GB+ download)
- **Storage**: 100GB+ free space
- **PowerShell**: Version 5.1 or later
- **Time**: 2-4 hours for downloads and packaging

### 1.2 Target Server (Air-Gapped)

The OMEN 35L server specifications:

- **OS**: Windows 11 Professional (fresh install recommended)
- **GPU**: NVIDIA RTX 4090 or similar (24GB+ VRAM)
- **RAM**: 32GB+ DDR4/DDR5
- **Storage**: 500GB+ NVMe SSD with 100GB+ free
- **Network**: Gigabit Ethernet connected to local network
- **Access**: Administrator privileges required

### 1.3 Client Workstations

Requirements for developer machines:

- **OS**: Windows 10/11, macOS, or Linux
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space
- **Network**: Connected to same local network as server
- **Software**: None (will be installed from package)

### 1.4 Transfer Media

- **USB Drive**: 128GB+ capacity (or external SSD)
- **Alternative**: Network file share (if air-gap allows local network transfers)

## 2. Phase 1: Preparation (Internet-Connected)

### 2.1 Setup Staging Directory

Open PowerShell as Administrator:

```powershell
# Create staging directory structure
New-Item -ItemType Directory -Path "C:\AirGapStaging" -Force
Set-Location C:\AirGapStaging

# Create subdirectories
New-Item -ItemType Directory -Path ".\installers" -Force
New-Item -ItemType Directory -Path ".\models" -Force
New-Item -ItemType Directory -Path ".\extensions" -Force
New-Item -ItemType Directory -Path ".\config" -Force
New-Item -ItemType Directory -Path ".\scripts" -Force
New-Item -ItemType Directory -Path ".\docs" -Force
```

### 2.2 Download Required Software

#### 2.2.1 Ollama for Windows

```powershell
# Download Ollama installer
$ollamaUrl = "https://ollama.com/download/OllamaSetup.exe"
Invoke-WebRequest -Uri $ollamaUrl -OutFile ".\installers\OllamaSetup.exe"
```

**Manual Alternative**: Visit https://ollama.com/download and download Windows installer

#### 2.2.2 VS Code

```powershell
# Download VS Code System Installer (recommended for enterprise)
$vscodeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-system"
Invoke-WebRequest -Uri $vscodeUrl -OutFile ".\installers\VSCodeSetup.exe"
```

**Manual Alternative**: Visit https://code.visualstudio.com/download

#### 2.2.3 NVIDIA CUDA Toolkit

```powershell
# Visit NVIDIA website and download CUDA Toolkit
# https://developer.nvidia.com/cuda-downloads
# Select: Windows > x86_64 > 11 > exe (local)
```

**Note**: Download version 12.0 or later. File will be ~3GB.

Save to: `C:\AirGapStaging\installers\cuda_12.x.x_windows.exe`

#### 2.2.4 NVIDIA Display Driver

```powershell
# Visit: https://www.nvidia.com/Download/index.aspx
# Select your GPU model (e.g., RTX 4090)
# Download latest production driver
```

Save to: `C:\AirGapStaging\installers\NVIDIA-Driver-xxx.xx.exe`

### 2.3 Install and Configure Ollama (Staging System)

```powershell
# Install Ollama on staging system
Start-Process -FilePath ".\installers\OllamaSetup.exe" -Wait

# Verify installation
ollama --version

# Check GPU detection (if staging system has NVIDIA GPU)
nvidia-smi
```

### 2.4 Download AI Models

**IMPORTANT**: This step requires significant bandwidth and time.

```powershell
# Set location for model downloads
cd C:\AirGapStaging

# Download primary coding model (19GB, ~30-60 minutes)
ollama pull qwen2.5-coder:32b-instruct-fp16

# Download reasoning model (19GB, ~30-60 minutes)
ollama pull deepseek-r1:32b

# Download backup model (9GB, ~15-30 minutes)
ollama pull qwen2.5-coder:14b

# Verify downloads
ollama list
```

**Expected Output**:
```
NAME                              ID            SIZE    MODIFIED
qwen2.5-coder:32b-instruct-fp16  abc123def     19 GB   2 minutes ago
deepseek-r1:32b                  def456ghi     19 GB   5 minutes ago
qwen2.5-coder:14b                ghi789jkl     9 GB    8 minutes ago
```

### 2.5 Create Custom Models with Extended Context

#### 2.5.1 Create Modelfile Directory

```powershell
New-Item -ItemType Directory -Path ".\config\modelfiles" -Force
cd .\config\modelfiles
```

#### 2.5.2 Create Qwen 32B Modelfile

Create file: `Modelfile-qwen32b`

```powershell
@"
FROM qwen2.5-coder:32b-instruct-fp16
PARAMETER num_ctx 131072
PARAMETER temperature 0.2
PARAMETER num_gpu 1
PARAMETER num_thread 8
SYSTEM You are an expert coding assistant. Provide clear, efficient, and well-documented code. Focus on best practices and maintainability.
"@ | Out-File -FilePath "Modelfile-qwen32b" -Encoding utf8
```

#### 2.5.3 Create DeepSeek R1 Modelfile

Create file: `Modelfile-deepseek32b`

```powershell
@"
FROM deepseek-r1:32b
PARAMETER num_ctx 131072
PARAMETER temperature 0.2
PARAMETER num_gpu 1
PARAMETER num_thread 8
SYSTEM You are an expert coding assistant with strong reasoning capabilities. Break down complex problems systematically and provide well-reasoned solutions.
"@ | Out-File -FilePath "Modelfile-deepseek32b" -Encoding utf8
```

#### 2.5.4 Create Qwen 14B Modelfile

Create file: `Modelfile-qwen14b`

```powershell
@"
FROM qwen2.5-coder:14b
PARAMETER num_ctx 131072
PARAMETER temperature 0.2
PARAMETER num_gpu 1
PARAMETER num_thread 8
SYSTEM You are an expert coding assistant. Provide clear, efficient, and well-documented code.
"@ | Out-File -FilePath "Modelfile-qwen14b" -Encoding utf8
```

#### 2.5.5 Build Custom Models

```powershell
# Return to staging root
cd C:\AirGapStaging

# Create custom models
ollama create qwen-32b-cline -f .\config\modelfiles\Modelfile-qwen32b
ollama create deepseek-r1-32b-cline -f .\config\modelfiles\Modelfile-deepseek32b
ollama create qwen-14b-cline -f .\config\modelfiles\Modelfile-qwen14b

# Verify custom models
ollama list
```

**Expected Output**:
```
NAME                              ID            SIZE    MODIFIED
qwen-32b-cline                   abc123new     19 GB   1 minute ago
deepseek-r1-32b-cline            def456new     19 GB   2 minutes ago
qwen-14b-cline                   ghi789new     9 GB    3 minutes ago
qwen2.5-coder:32b-instruct-fp16  abc123def     19 GB   1 hour ago
deepseek-r1:32b                  def456ghi     19 GB   1 hour ago
qwen2.5-coder:14b                ghi789jkl     9 GB    1 hour ago
```

### 2.6 Download Cline Extension

#### Method 1: Direct Download

```powershell
# Download Cline extension from VS Code Marketplace
$clineUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/saoudrizwan/vsextensions/claude-dev/latest/vspackage"
Invoke-WebRequest -Uri $clineUrl -OutFile ".\extensions\cline.vsix"
```

#### Method 2: Manual Download

1. Visit: https://marketplace.visualstudio.com/items?itemName=saoudrizwan.claude-dev
2. Click "Download Extension" on the right sidebar
3. Save to: `C:\AirGapStaging\extensions\cline.vsix`

### 2.7 Package Models for Transfer

```powershell
# Locate Ollama model directory
$ollamaModels = "$env:USERPROFILE\.ollama\models"

# Copy models to staging area
Copy-Item -Path $ollamaModels -Destination ".\models" -Recurse -Force

Write-Host "Models copied successfully!" -ForegroundColor Green
```

### 2.8 Create Installation Scripts

#### 2.8.1 Server Installation Script

Create file: `scripts\install-server.ps1`

```powershell
@'
#Requires -RunAsAdministrator

Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  AirGapAICoder Server Installation        " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check prerequisites
Write-Host "Step 1: Checking prerequisites..." -ForegroundColor Green
$nvidiaSmi = Test-Path "C:\Windows\System32\nvidia-smi.exe"
if (-not $nvidiaSmi) {
    Write-Host "⚠ NVIDIA driver not detected" -ForegroundColor Yellow
    Write-Host "Please install NVIDIA driver first" -ForegroundColor Yellow
    Write-Host "Press Enter to continue anyway or Ctrl+C to exit..."
    Read-Host
}

# Step 2: Install Ollama
Write-Host ""
Write-Host "Step 2: Installing Ollama..." -ForegroundColor Green
if (-not (Test-Path ".\installers\OllamaSetup.exe")) {
    Write-Host "ERROR: OllamaSetup.exe not found!" -ForegroundColor Red
    exit 1
}

Start-Process -FilePath ".\installers\OllamaSetup.exe" -ArgumentList "/SILENT" -Wait
Write-Host "✓ Ollama installed" -ForegroundColor Green

# Step 3: Copy models
Write-Host ""
Write-Host "Step 3: Copying models (this may take several minutes)..." -ForegroundColor Green
$targetPath = "$env:USERPROFILE\.ollama"
if (-not (Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
}

Copy-Item -Path ".\models\*" -Destination "$targetPath\models" -Recurse -Force
Write-Host "✓ Models copied successfully" -ForegroundColor Green

# Step 4: Configure environment variables
Write-Host ""
Write-Host "Step 4: Configuring environment variables..." -ForegroundColor Green
[Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0:11434", "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_NUM_PARALLEL", "1", "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_MAX_LOADED_MODELS", "1", "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_FLASH_ATTENTION", "1", "Machine")
Write-Host "✓ Environment configured" -ForegroundColor Green

# Step 5: Configure Windows Firewall
Write-Host ""
Write-Host "Step 5: Configuring Windows Firewall..." -ForegroundColor Green
$firewallRule = Get-NetFirewallRule -DisplayName "Ollama" -ErrorAction SilentlyContinue
if (-not $firewallRule) {
    New-NetFirewallRule -DisplayName "Ollama" -Direction Inbound -Port 11434 -Protocol TCP -Action Allow | Out-Null
    Write-Host "✓ Firewall rule created" -ForegroundColor Green
} else {
    Write-Host "✓ Firewall rule already exists" -ForegroundColor Green
}

# Step 6: Start Ollama
Write-Host ""
Write-Host "Step 6: Starting Ollama server..." -ForegroundColor Green
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
Start-Sleep -Seconds 5
Write-Host "✓ Ollama server started" -ForegroundColor Green

# Step 7: Verify installation
Write-Host ""
Write-Host "Step 7: Verifying installation..." -ForegroundColor Green
Start-Sleep -Seconds 3
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -ErrorAction Stop
    Write-Host "✓ Server is responding" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available models:" -ForegroundColor Cyan
    $response.models | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor White }
} catch {
    Write-Host "⚠ Server not responding yet, may need more time" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Installation Complete!                   " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server is running at: http://localhost:11434" -ForegroundColor Green
Write-Host "Network access: http://YOUR_IP:11434" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Find your server IP: ipconfig" -ForegroundColor White
Write-Host "2. Test from client: Invoke-RestMethod -Uri http://SERVER_IP:11434/api/tags" -ForegroundColor White
Write-Host "3. Install VS Code and Cline on client workstations" -ForegroundColor White
Write-Host ""
Write-Host "To test a model locally:" -ForegroundColor Yellow
Write-Host "  ollama run qwen-32b-cline ""Write a Python function""" -ForegroundColor White
Write-Host ""
'@ | Out-File -FilePath ".\scripts\install-server.ps1" -Encoding utf8
```

#### 2.8.2 Client Installation Script

Create file: `scripts\install-client.ps1`

```powershell
@'
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  AirGapAICoder Client Installation        " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Get server IP from user
$serverIP = Read-Host "Enter the Ollama server IP address"

# Step 1: Install VS Code
Write-Host ""
Write-Host "Step 1: Installing VS Code..." -ForegroundColor Green
if (Test-Path ".\installers\VSCodeSetup.exe") {
    Start-Process -FilePath ".\installers\VSCodeSetup.exe" -ArgumentList "/VERYSILENT /MERGETASKS=!runcode" -Wait
    Write-Host "✓ VS Code installed" -ForegroundColor Green
} else {
    Write-Host "⚠ VSCodeSetup.exe not found, skipping" -ForegroundColor Yellow
}

# Step 2: Install Cline extension
Write-Host ""
Write-Host "Step 2: Installing Cline extension..." -ForegroundColor Green
if (Test-Path ".\extensions\cline.vsix") {
    & code --install-extension ".\extensions\cline.vsix"
    Write-Host "✓ Cline extension installed" -ForegroundColor Green
} else {
    Write-Host "⚠ cline.vsix not found, skipping" -ForegroundColor Yellow
}

# Step 3: Configure Cline
Write-Host ""
Write-Host "Step 3: Configuring Cline..." -ForegroundColor Green
$configPath = "$env:APPDATA\Code\User\globalStorage\saoudrizwan.claude-dev\settings"
New-Item -ItemType Directory -Path $configPath -Force | Out-Null

$config = @"
{
  "apiModelOverride": {
    "modelId": "qwen-32b-cline",
    "apiProvider": "ollama",
    "baseUrl": "http://${serverIP}:11434"
  },
  "customModelOverride": [
    {
      "id": "qwen-32b-cline",
      "name": "Qwen 2.5 Coder 32B (Local)",
      "contextWindow": 131072,
      "maxTokens": 8192,
      "supportsPromptCache": false,
      "supportsComputerUse": true,
      "supportsImages": false,
      "inputPrice": 0,
      "outputPrice": 0
    },
    {
      "id": "deepseek-r1-32b-cline",
      "name": "DeepSeek R1 32B (Local)",
      "contextWindow": 131072,
      "maxTokens": 8192,
      "supportsPromptCache": false,
      "supportsComputerUse": true,
      "supportsImages": false,
      "inputPrice": 0,
      "outputPrice": 0
    },
    {
      "id": "qwen-14b-cline",
      "name": "Qwen 2.5 Coder 14B (Local)",
      "contextWindow": 131072,
      "maxTokens": 4096,
      "supportsPromptCache": false,
      "supportsComputerUse": true,
      "supportsImages": false,
      "inputPrice": 0,
      "outputPrice": 0
    }
  ]
}
"@

$config | Out-File -FilePath "$configPath\cline_mcp_settings.json" -Encoding utf8
Write-Host "✓ Cline configured for server: http://${serverIP}:11434" -ForegroundColor Green

# Step 4: Test connection
Write-Host ""
Write-Host "Step 4: Testing connection to server..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://${serverIP}:11434/api/tags" -ErrorAction Stop
    Write-Host "✓ Successfully connected to server!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available models:" -ForegroundColor Cyan
    $response.models | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor White }
} catch {
    Write-Host "✗ Cannot connect to server at http://${serverIP}:11434" -ForegroundColor Red
    Write-Host "Please verify:" -ForegroundColor Yellow
    Write-Host "  1. Server IP is correct" -ForegroundColor White
    Write-Host "  2. Ollama is running on server" -ForegroundColor White
    Write-Host "  3. Firewall allows port 11434" -ForegroundColor White
    Write-Host "  4. Client and server are on same network" -ForegroundColor White
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Client Installation Complete!            " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Launch VS Code: code" -ForegroundColor White
Write-Host "2. Open Cline: Click Cline icon in sidebar or Ctrl+Shift+P > 'Cline: Open'" -ForegroundColor White
Write-Host "3. Start coding with AI assistance!" -ForegroundColor White
Write-Host ""
'@ | Out-File -FilePath ".\scripts\install-client.ps1" -Encoding utf8
```

### 2.9 Create Documentation

Copy relevant documentation to staging:

```powershell
# If you have the AirGapAICoder repo
Copy-Item -Path "path\to\repo\docs\*" -Destination ".\docs\" -Recurse

# Or create a README
@"
# AirGapAICoder Installation Package

This package contains everything needed to install AirGapAICoder in an air-gapped environment.

## Contents
- Ollama server installer
- VS Code installer
- Cline extension
- AI models (Qwen 32B, DeepSeek R1, Qwen 14B)
- NVIDIA drivers and CUDA toolkit
- Installation scripts
- Configuration files

## Installation Instructions

See docs/INSTALLATION.md for complete installation guide.

## Quick Start

### Server Installation
1. Copy entire package to server
2. Open PowerShell as Administrator
3. Run: .\scripts\install-server.ps1

### Client Installation
1. Copy installers and extensions to client
2. Open PowerShell
3. Run: .\scripts\install-client.ps1

## Package Information
- Total Size: ~50GB
- Models: 3 (Qwen 32B, DeepSeek R1 32B, Qwen 14B)
- Created: $(Get-Date -Format 'yyyy-MM-dd')

## Support
For issues or questions, see docs/TROUBLESHOOTING.md
"@ | Out-File -FilePath ".\README.txt" -Encoding utf8
```

### 2.10 Create Package Manifest

```powershell
@"
╔════════════════════════════════════════════════════════════╗
║          AIRGAPAICODER INSTALLATION PACKAGE                ║
╚════════════════════════════════════════════════════════════╝

Package Information:
--------------------
Version: 1.0
Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Created By: $env:USERNAME
Total Size: ~50GB

Components Included:
--------------------
✓ Ollama Server (Windows x64)
✓ VS Code System Installer
✓ Cline Extension (.vsix)
✓ NVIDIA Display Driver
✓ CUDA Toolkit 12.x
✓ AI Models:
  - qwen-32b-cline (19GB, 131k context)
  - deepseek-r1-32b-cline (19GB, 131k context)
  - qwen-14b-cline (9GB, 131k context)
✓ Installation Scripts (PowerShell)
✓ Configuration Templates
✓ Documentation

Target System Requirements:
---------------------------
• Windows 11 Professional
• NVIDIA GPU with 24GB+ VRAM
• 32GB+ System RAM
• 100GB+ Free Storage
• Local Network Connectivity

Installation Time:
------------------
• Server: ~30 minutes
• Client: ~5 minutes per workstation

Next Steps:
-----------
1. Transfer this package to target server via USB
2. Follow docs/INSTALLATION.md for complete instructions
3. Run scripts/install-server.ps1 on server
4. Run scripts/install-client.ps1 on each client

Package Checksums:
------------------
(Generate checksums for verification)
"@ | Out-File -FilePath ".\MANIFEST.txt" -Encoding utf8
```

### 2.11 Create Transfer Package

```powershell
# Option 1: ZIP compression (if package fits on single drive)
Write-Host "Creating transfer package..." -ForegroundColor Yellow
Compress-Archive -Path "C:\AirGapStaging\*" -DestinationPath "C:\airgap-install.zip" -CompressionLevel Optimal

# Option 2: 7-Zip for better compression and splitting
# If package is too large for single USB drive
# Install 7-Zip, then:
# & "C:\Program Files\7-Zip\7z.exe" a -v4g C:\airgap-install.7z C:\AirGapStaging\*

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Package Creation Complete!               " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
$packageInfo = Get-Item "C:\airgap-install.zip"
Write-Host "Package Location: $($packageInfo.FullName)" -ForegroundColor Cyan
Write-Host "Package Size: $([math]::Round($packageInfo.Length / 1GB, 2)) GB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Copy package to USB drive or external storage" -ForegroundColor White
Write-Host "2. Transfer to air-gapped server" -ForegroundColor White
Write-Host "3. Extract and run installation scripts" -ForegroundColor White
```

## 3. Phase 2: Transfer to Air-Gap

### 3.1 Copy to USB Drive

```powershell
# Assuming USB drive is F:
$usbDrive = "F:"
Copy-Item -Path "C:\airgap-install.zip" -Destination "$usbDrive\" -Force

Write-Host "Package copied to USB drive" -ForegroundColor Green
```

### 3.2 Verify Transfer

```powershell
# Calculate checksum on staging system
$hash1 = Get-FileHash -Path "C:\airgap-install.zip" -Algorithm SHA256
Write-Host "Source SHA256: $($hash1.Hash)" -ForegroundColor Cyan

# After transfer, verify on USB
$hash2 = Get-FileHash -Path "$usbDrive\airgap-install.zip" -Algorithm SHA256
Write-Host "USB SHA256: $($hash2.Hash)" -ForegroundColor Cyan

if ($hash1.Hash -eq $hash2.Hash) {
    Write-Host "✓ Transfer verified successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Checksum mismatch! Transfer may be corrupted" -ForegroundColor Red
}
```

## 4. Phase 3: Server Installation

### 4.1 Prerequisites Check

On the target server, open PowerShell as Administrator:

```powershell
# Check Windows version
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"

# Check available disk space
Get-PSDrive C | Select-Object Used,Free

# Check if NVIDIA GPU is detected (may not work without driver)
Get-PnpDevice | Where-Object {$_.FriendlyName -like "*NVIDIA*"}
```

### 4.2 Extract Installation Package

```powershell
# Assuming USB drive is E: on target server
$usbDrive = "E:"

# Create installation directory
New-Item -ItemType Directory -Path "C:\AirGapInstall" -Force
Set-Location C:\AirGapInstall

# Extract package
Expand-Archive -Path "$usbDrive\airgap-install.zip" -DestinationPath "." -Force

Write-Host "Package extracted successfully" -ForegroundColor Green
```

### 4.3 Install NVIDIA Driver (if needed)

```powershell
# Check if NVIDIA driver is already installed
$nvidiaDriver = Get-WmiObject Win32_VideoController | Where-Object {$_.Name -like "*NVIDIA*"}

if (-not $nvidiaDriver) {
    Write-Host "Installing NVIDIA driver..." -ForegroundColor Yellow
    Start-Process -FilePath ".\installers\NVIDIA-Driver-xxx.xx.exe" -ArgumentList "/s /n" -Wait
    Write-Host "✓ Driver installed. Reboot required!" -ForegroundColor Yellow
    Write-Host "Press Enter to reboot now, or Ctrl+C to reboot later..."
    Read-Host
    Restart-Computer -Force
} else {
    Write-Host "✓ NVIDIA driver already installed" -ForegroundColor Green
}
```

### 4.4 Install CUDA Toolkit (if needed)

```powershell
# Check if CUDA is installed
$cudaPath = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA"

if (-not (Test-Path $cudaPath)) {
    Write-Host "Installing CUDA Toolkit..." -ForegroundColor Yellow
    Start-Process -FilePath ".\installers\cuda_12.x.x_windows.exe" -ArgumentList "-s" -Wait
    Write-Host "✓ CUDA Toolkit installed" -ForegroundColor Green
} else {
    Write-Host "✓ CUDA already installed" -ForegroundColor Green
}

# Verify CUDA installation
nvidia-smi
```

### 4.5 Run Server Installation Script

```powershell
# Run the automated installation script
Set-Location C:\AirGapInstall
.\scripts\install-server.ps1
```

The script will:
1. Check prerequisites
2. Install Ollama
3. Copy model files (~47GB)
4. Configure environment variables
5. Configure Windows Firewall
6. Start Ollama server
7. Verify installation

**Installation Time**: 20-30 minutes (mostly copying models)

### 4.6 Verify Server Installation

```powershell
# Check Ollama is running
Get-Process -Name "ollama" -ErrorAction SilentlyContinue

# Test local API
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"

# Check GPU utilization
nvidia-smi

# List available models
ollama list

# Test inference
ollama run qwen-32b-cline "Write a Python function to calculate factorial"
```

### 4.7 Get Server IP Address

```powershell
# Get server IP address for clients
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object IPAddress, InterfaceAlias

# Or simpler:
ipconfig | findstr IPv4
```

**Note the IP address** (e.g., 192.168.1.100) - you'll need this for client setup.

## 5. Phase 4: Client Setup

### 5.1 Copy Client Files

You can either:
- **Option A**: Copy entire package to each client
- **Option B**: Copy only required files:
  - `installers\VSCodeSetup.exe`
  - `extensions\cline.vsix`
  - `scripts\install-client.ps1`

### 5.2 Run Client Installation Script

On each client workstation, open PowerShell:

```powershell
# Navigate to installation files
Set-Location "path\to\install\files"

# Run client installation
.\scripts\install-client.ps1

# When prompted, enter the server IP address (from 4.7)
# Example: 192.168.1.100
```

The script will:
1. Install VS Code
2. Install Cline extension
3. Configure Cline to connect to server
4. Test connection

**Installation Time**: ~5 minutes per client

### 5.3 Manual Cline Configuration (Alternative)

If automatic configuration doesn't work:

1. **Launch VS Code**
2. **Open Cline**: Click Cline icon in sidebar (or Ctrl+Shift+P → "Cline: Open")
3. **Click Settings** (gear icon ⚙️)
4. **Configure API Provider**:
   - API Provider: `Ollama`
   - Base URL: `http://SERVER_IP:11434` (replace SERVER_IP)
   - Model ID: `qwen-32b-cline`
5. **Advanced Settings**:
   - Context Window: `131072`
   - Max Tokens: `8192`
   - Temperature: `0.2`
6. **Save Configuration**

### 5.4 Test Client Connection

```powershell
# Test API connectivity from client
$serverIP = "192.168.1.100"  # Replace with your server IP
Invoke-RestMethod -Uri "http://${serverIP}:11434/api/tags"
```

**Expected Output**: JSON list of available models

## 6. Phase 5: Verification

### 6.1 End-to-End Test

1. **Open VS Code** on client workstation
2. **Open a test project** or create new folder
3. **Launch Cline** (click icon in sidebar)
4. **Start a conversation**:
   ```
   Create a Python function that calculates the Fibonacci sequence using memoization
   ```
5. **Verify response**: Should receive AI-generated code within 5-10 seconds

### 6.2 Performance Verification

On the server, monitor GPU utilization during client request:

```powershell
# Real-time GPU monitoring
nvidia-smi -l 1
```

**Expected**:
- GPU Utilization: 80-100% during inference
- Memory Used: ~20GB for 32B model
- Temperature: < 85°C

### 6.3 Multi-User Test

1. **Connect 3 clients** simultaneously
2. **Send concurrent requests** from each client
3. **Monitor server performance**:
   ```powershell
   # Check Ollama process
   Get-Process ollama | Format-List *

   # Monitor GPU
   nvidia-smi
   ```

**Expected**:
- Requests queued and processed sequentially
- No crashes or errors
- Reasonable response times (may be slower under load)

### 6.4 Model Switching Test

Test switching between models:

```powershell
# On server
ollama run qwen-32b-cline "Test message"
ollama run deepseek-r1-32b-cline "Test message"
ollama run qwen-14b-cline "Test message"
```

**Expected**: Each model loads within 10-15 seconds

## 7. Troubleshooting

### 7.1 Server Issues

#### Ollama Won't Start

```powershell
# Check if another instance is running
Get-Process -Name "ollama" -ErrorAction SilentlyContinue | Stop-Process -Force

# Check logs
Get-Content "$env:LOCALAPPDATA\Ollama\logs\server.log" -Tail 50

# Restart service
ollama serve
```

#### GPU Not Detected

```powershell
# Verify NVIDIA driver
nvidia-smi

# Check CUDA installation
nvcc --version

# Reinstall NVIDIA driver if needed
```

#### Models Not Loading

```powershell
# Check model files
Get-ChildItem "$env:USERPROFILE\.ollama\models" -Recurse

# Re-copy models from package
Copy-Item -Path "C:\AirGapInstall\models\*" -Destination "$env:USERPROFILE\.ollama\models" -Recurse -Force

# Verify models
ollama list
```

### 7.2 Network Issues

#### Clients Can't Connect

```powershell
# On server, check firewall
Get-NetFirewallRule -DisplayName "Ollama"

# Test from server
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"

# Check Ollama is listening on network
netstat -an | Select-String "11434"

# Verify OLLAMA_HOST environment variable
[Environment]::GetEnvironmentVariable("OLLAMA_HOST", "Machine")

# Should be: 0.0.0.0:11434
```

#### Firewall Blocking

```powershell
# Recreate firewall rule
Remove-NetFirewallRule -DisplayName "Ollama" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Ollama" -Direction Inbound -Port 11434 -Protocol TCP -Action Allow

# Or temporarily disable firewall for testing (NOT recommended for production)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

### 7.3 Client Issues

#### Cline Not Connecting

1. **Verify server IP** in Cline settings
2. **Test connection** from PowerShell:
   ```powershell
   Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/tags"
   ```
3. **Check Cline configuration**:
   - Open: `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`
   - Verify `baseUrl` is correct

#### Cline Extension Not Working

```powershell
# Reinstall extension
code --uninstall-extension saoudrizwan.claude-dev
code --install-extension "path\to\cline.vsix"

# Check VS Code logs
# Help > Toggle Developer Tools > Console tab
```

### 7.4 Performance Issues

#### Slow Response Times

```powershell
# Check GPU utilization
nvidia-smi

# Check system resources
Get-Process ollama | Select-Object CPU, @{Name="Memory(GB)";Expression={[math]::Round($_.WS / 1GB, 2)}}

# Optimize: Set high priority
$process = Get-Process -Name "ollama"
$process.PriorityClass = "High"

# Optimize: Set power plan to High Performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
```

#### Out of Memory Errors

```powershell
# Check VRAM usage
nvidia-smi

# Unload all models
ollama ps
# (manually stop any running inference)

# Try smaller model
ollama run qwen-14b-cline "Test"
```

### 7.5 Getting Help

**Check Logs**:
- Server: `%LOCALAPPDATA%\Ollama\logs\`
- Windows Events: Event Viewer > Application

**Diagnostic Commands**:
```powershell
# System info
systeminfo

# GPU info
nvidia-smi -q

# Network info
ipconfig /all

# Ollama status
ollama ps
ollama list

# Test inference
ollama run qwen-32b-cline "Hello"
```

---

## Appendix A: Quick Reference

### Server Management Commands

```powershell
# Start Ollama server
ollama serve

# Start in background
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden

# Stop Ollama
Stop-Process -Name "ollama" -Force

# Check status
Get-Process -Name "ollama"
ollama ps

# List models
ollama list

# Run model
ollama run qwen-32b-cline "Your prompt"

# Monitor GPU
nvidia-smi -l 1

# View logs
Get-Content "$env:LOCALAPPDATA\Ollama\logs\server.log" -Tail 50 -Wait
```

### Client Commands

```powershell
# Test server connection
Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/tags"

# Launch VS Code
code

# Open Cline in VS Code
# Ctrl+Shift+P > "Cline: Open"
```

### Environment Variables

```powershell
# View current settings
[Environment]::GetEnvironmentVariable("OLLAMA_HOST", "Machine")
[Environment]::GetEnvironmentVariable("OLLAMA_NUM_PARALLEL", "Machine")
[Environment]::GetEnvironmentVariable("OLLAMA_MAX_LOADED_MODELS", "Machine")
[Environment]::GetEnvironmentVariable("OLLAMA_FLASH_ATTENTION", "Machine")

# Modify settings (requires restart)
[Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0:11434", "Machine")
```

---

**Document Control**:
- **Location**: `/docs/INSTALLATION.md`
- **Maintained by**: System Administrator
- **Review Frequency**: On version updates
