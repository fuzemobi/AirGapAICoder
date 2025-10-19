# AirGapAICoder - Operations Guide

## Document Information

- **Version**: 1.0
- **Date**: 2025-10-19
- **Audience**: System Administrators, Operations Team

## 1. Daily Operations

### 1.1 Starting the Server

**Automatic Startup** (Recommended):

Create a scheduled task to start Ollama on boot:

```powershell
# Create startup task
$action = New-ScheduledTaskAction -Execute "ollama.exe" -Argument "serve"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName "OllamaServer" -Action $action -Trigger $trigger -Principal $principal
```

**Manual Startup**:

```powershell
# Start Ollama server
ollama serve

# Or start in background
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
```

### 1.2 Stopping the Server

```powershell
# Graceful shutdown
Stop-Process -Name "ollama" -Force

# Verify stopped
Get-Process -Name "ollama" -ErrorAction SilentlyContinue
```

### 1.3 Checking Server Status

```powershell
# Check if Ollama is running
Get-Process -Name "ollama" -ErrorAction SilentlyContinue

# Check API status
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"

# Check loaded models
ollama ps

# Check GPU status
nvidia-smi
```

## 2. Monitoring

### 2.1 Performance Monitoring

**GPU Monitoring**:

```powershell
# Real-time GPU stats
nvidia-smi -l 1

# Detailed GPU info
nvidia-smi -q

# GPU utilization and memory
nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv -l 5
```

**System Resource Monitoring**:

```powershell
# Ollama process stats
Get-Process ollama | Select-Object Name, CPU, @{Name="Memory(GB)";Expression={[math]::Round($_.WS / 1GB, 2)}}

# Continuous monitoring (updates every 5 seconds)
while ($true) {
    Clear-Host
    Write-Host "Ollama Server Status" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    Get-Process ollama -ErrorAction SilentlyContinue | Select-Object Name, CPU, @{Name="Memory(GB)";Expression={[math]::Round($_.WS / 1GB, 2)}}
    Start-Sleep -Seconds 5
}
```

**Network Monitoring**:

```powershell
# Check active connections
netstat -an | Select-String "11434"

# Monitor request rate (requires logging enabled)
Get-Content "$env:LOCALAPPDATA\Ollama\logs\server.log" -Tail 20 -Wait
```

### 2.2 Health Checks

Create a health check script: `scripts\health-check.ps1`

```powershell
#Requires -Version 5.1

Write-Host "AirGapAICoder Health Check" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: Ollama process
Write-Host "[1] Checking Ollama process..." -NoNewline
$ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
if ($ollamaProcess) {
    Write-Host " ✓ Running" -ForegroundColor Green
} else {
    Write-Host " ✗ Not running" -ForegroundColor Red
    $allGood = $false
}

# Check 2: API responsiveness
Write-Host "[2] Checking API endpoint..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 -ErrorAction Stop
    Write-Host " ✓ Responsive" -ForegroundColor Green
} catch {
    Write-Host " ✗ Not responding" -ForegroundColor Red
    $allGood = $false
}

# Check 3: GPU availability
Write-Host "[3] Checking GPU..." -NoNewline
try {
    $gpuInfo = nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
    Write-Host " ✓ Available ($gpuInfo)" -ForegroundColor Green
} catch {
    Write-Host " ✗ Not detected" -ForegroundColor Red
    $allGood = $false
}

# Check 4: VRAM usage
Write-Host "[4] Checking VRAM usage..." -NoNewline
try {
    $vramUsage = nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits
    $vramParts = $vramUsage -split ','
    $usedGB = [math]::Round($vramParts[0] / 1024, 1)
    $totalGB = [math]::Round($vramParts[1] / 1024, 1)
    $percentUsed = [math]::Round(($vramParts[0] / $vramParts[1]) * 100, 1)

    if ($percentUsed -lt 90) {
        Write-Host " ✓ ${usedGB}GB / ${totalGB}GB ($percentUsed%)" -ForegroundColor Green
    } else {
        Write-Host " ⚠ ${usedGB}GB / ${totalGB}GB ($percentUsed%) - High usage!" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ✗ Cannot read" -ForegroundColor Red
}

# Check 5: Disk space
Write-Host "[5] Checking disk space..." -NoNewline
$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free / 1GB, 1)
if ($freeGB -gt 20) {
    Write-Host " ✓ ${freeGB}GB free" -ForegroundColor Green
} else {
    Write-Host " ⚠ ${freeGB}GB free - Low disk space!" -ForegroundColor Yellow
}

# Check 6: Models available
Write-Host "[6] Checking models..." -NoNewline
try {
    $models = ollama list 2>$null
    if ($models) {
        $modelCount = ($models | Measure-Object).Count - 1  # Subtract header
        Write-Host " ✓ $modelCount model(s) available" -ForegroundColor Green
    } else {
        Write-Host " ⚠ No models found" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ✗ Cannot list models" -ForegroundColor Red
}

# Check 7: Network accessibility
Write-Host "[7] Checking network access..." -NoNewline
$listening = netstat -an | Select-String "0.0.0.0:11434.*LISTENING"
if ($listening) {
    Write-Host " ✓ Listening on all interfaces" -ForegroundColor Green
} else {
    Write-Host " ⚠ Not listening on network" -ForegroundColor Yellow
}

Write-Host ""
if ($allGood) {
    Write-Host "Overall Status: ✓ HEALTHY" -ForegroundColor Green
} else {
    Write-Host "Overall Status: ✗ ISSUES DETECTED" -ForegroundColor Red
}
Write-Host ""
```

**Run health check**:

```powershell
.\scripts\health-check.ps1
```

### 2.3 Performance Metrics

Key metrics to track:

| Metric | How to Check | Healthy Range |
|--------|--------------|---------------|
| **GPU Utilization** | `nvidia-smi` | 80-100% during inference, <10% idle |
| **VRAM Usage** | `nvidia-smi` | <90% of total |
| **CPU Usage** | Task Manager | <50% average |
| **Memory Usage** | Task Manager | <80% of total RAM |
| **Disk Usage** | `Get-PSDrive C` | >20GB free |
| **Response Time** | Test inference | <5s for first token |
| **Tokens/Second** | During generation | >50 tokens/s |

## 3. Model Management

### 3.1 Listing Models

```powershell
# List all models
ollama list

# Show detailed model info
ollama show qwen-32b-cline
```

### 3.2 Loading/Unloading Models

```powershell
# Models load automatically on first use
# To preload a model:
ollama run qwen-32b-cline ""

# To unload all models (restart Ollama):
Stop-Process -Name "ollama" -Force
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
```

### 3.3 Switching Models

Users can switch models in Cline:
1. Open Cline settings
2. Change "Model ID" to desired model:
   - `qwen-32b-cline` (default, best quality)
   - `deepseek-r1-32b-cline` (reasoning focus)
   - `qwen-14b-cline` (faster, lower VRAM)

### 3.4 Adding New Models

If you need to add a new model (requires internet access on staging system):

1. **On staging system**:
   ```powershell
   # Pull new model
   ollama pull new-model:tag

   # Create custom version if needed
   ollama create new-model-cline -f Modelfile-newmodel

   # Package for transfer
   Copy-Item -Path "$env:USERPROFILE\.ollama\models" -Destination "C:\NewModelPackage\models" -Recurse
   ```

2. **Transfer to air-gap server**

3. **On air-gap server**:
   ```powershell
   # Copy new model files
   Copy-Item -Path "E:\NewModelPackage\models\*" -Destination "$env:USERPROFILE\.ollama\models" -Recurse -Force

   # Verify
   ollama list
   ```

## 4. User Management

### 4.1 Adding New Clients

For each new developer workstation:

1. **Copy client installation files**:
   - `VSCodeSetup.exe`
   - `cline.vsix`
   - `install-client.ps1`

2. **Run client installation**:
   ```powershell
   .\install-client.ps1
   # Enter server IP when prompted
   ```

3. **Verify connectivity**:
   ```powershell
   Invoke-RestMethod -Uri "http://SERVER_IP:11434/api/tags"
   ```

### 4.2 Restricting Access (Optional)

To limit which clients can connect:

```powershell
# Remove existing firewall rule
Remove-NetFirewallRule -DisplayName "Ollama"

# Add rule with specific IP range
New-NetFirewallRule -DisplayName "Ollama" `
    -Direction Inbound `
    -Port 11434 `
    -Protocol TCP `
    -Action Allow `
    -RemoteAddress "192.168.1.0/24"  # Adjust to your network

# Or allow specific IPs only
New-NetFirewallRule -DisplayName "Ollama" `
    -Direction Inbound `
    -Port 11434 `
    -Protocol TCP `
    -Action Allow `
    -RemoteAddress "192.168.1.10","192.168.1.11","192.168.1.12"
```

## 5. Backup and Recovery

### 5.1 What to Backup

Critical components:
1. **Models** (~50GB) - `%USERPROFILE%\.ollama\models`
2. **Configuration**:
   - Environment variables
   - Modelfiles
   - Firewall rules
3. **Logs** (optional) - `%LOCALAPPDATA%\Ollama\logs`

### 5.2 Backup Procedure

```powershell
# Create backup directory
$backupDate = Get-Date -Format "yyyy-MM-dd"
New-Item -ItemType Directory -Path "E:\Backups\AirGapAICoder-$backupDate" -Force

# Backup models (this takes time!)
Copy-Item -Path "$env:USERPROFILE\.ollama\models" `
    -Destination "E:\Backups\AirGapAICoder-$backupDate\models" `
    -Recurse -Force

# Backup configuration
@{
    OLLAMA_HOST = [Environment]::GetEnvironmentVariable("OLLAMA_HOST", "Machine")
    OLLAMA_NUM_PARALLEL = [Environment]::GetEnvironmentVariable("OLLAMA_NUM_PARALLEL", "Machine")
    OLLAMA_MAX_LOADED_MODELS = [Environment]::GetEnvironmentVariable("OLLAMA_MAX_LOADED_MODELS", "Machine")
    OLLAMA_FLASH_ATTENTION = [Environment]::GetEnvironmentVariable("OLLAMA_FLASH_ATTENTION", "Machine")
} | ConvertTo-Json | Out-File "E:\Backups\AirGapAICoder-$backupDate\config.json"

# Backup Modelfiles
Copy-Item -Path "C:\AirGapInstall\config\modelfiles" `
    -Destination "E:\Backups\AirGapAICoder-$backupDate\modelfiles" `
    -Recurse -Force

Write-Host "Backup completed: E:\Backups\AirGapAICoder-$backupDate" -ForegroundColor Green
```

### 5.3 Restore Procedure

```powershell
# Stop Ollama
Stop-Process -Name "ollama" -Force

# Restore models
Copy-Item -Path "E:\Backups\AirGapAICoder-YYYY-MM-DD\models\*" `
    -Destination "$env:USERPROFILE\.ollama\models" `
    -Recurse -Force

# Restore configuration
$config = Get-Content "E:\Backups\AirGapAICoder-YYYY-MM-DD\config.json" | ConvertFrom-Json
[Environment]::SetEnvironmentVariable("OLLAMA_HOST", $config.OLLAMA_HOST, "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_NUM_PARALLEL", $config.OLLAMA_NUM_PARALLEL, "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_MAX_LOADED_MODELS", $config.OLLAMA_MAX_LOADED_MODELS, "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_FLASH_ATTENTION", $config.OLLAMA_FLASH_ATTENTION, "Machine")

# Restart Ollama
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden

# Verify
ollama list
```

## 6. Maintenance

### 6.1 Log Rotation

Ollama logs can grow over time:

```powershell
# Check log size
Get-ChildItem "$env:LOCALAPPDATA\Ollama\logs" -Recurse | Measure-Object -Property Length -Sum

# Archive old logs
$archiveDate = Get-Date -Format "yyyy-MM-dd"
Compress-Archive -Path "$env:LOCALAPPDATA\Ollama\logs\*" `
    -DestinationPath "C:\LogArchives\ollama-logs-$archiveDate.zip"

# Clear logs (after archiving!)
Remove-Item "$env:LOCALAPPDATA\Ollama\logs\*" -Force
```

### 6.2 Disk Cleanup

Free up disk space:

```powershell
# Check Ollama cache size
Get-ChildItem "$env:USERPROFILE\.ollama" -Recurse | Measure-Object -Property Length -Sum

# Remove unused models
ollama list
ollama rm unused-model-name

# Clean Windows temp files
Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
```

### 6.3 Performance Optimization

```powershell
# Set Ollama process to High priority (persists until restart)
$process = Get-Process -Name "ollama"
$process.PriorityClass = "High"

# Set Windows power plan to High Performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable unnecessary Windows services
# (Research before disabling - may affect other functionality)
```

### 6.4 Update NVIDIA Drivers

During planned maintenance windows:

1. **Download latest NVIDIA driver** (on internet-connected system)
2. **Transfer to server**
3. **Backup current configuration**
4. **Stop Ollama**:
   ```powershell
   Stop-Process -Name "ollama" -Force
   ```
5. **Install new driver**:
   ```powershell
   Start-Process -FilePath ".\NVIDIA-Driver-new.exe" -ArgumentList "/s /n" -Wait
   ```
6. **Reboot server**:
   ```powershell
   Restart-Computer -Force
   ```
7. **Verify GPU after reboot**:
   ```powershell
   nvidia-smi
   ```
8. **Start Ollama and test**:
   ```powershell
   ollama serve
   ollama run qwen-32b-cline "Test after update"
   ```

## 7. Troubleshooting

### 7.1 Common Issues

#### Server Becomes Unresponsive

```powershell
# Restart Ollama
Stop-Process -Name "ollama" -Force
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden

# If still unresponsive, check logs
Get-Content "$env:LOCALAPPDATA\Ollama\logs\server.log" -Tail 100
```

#### High GPU Temperature

```powershell
# Check temperature
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader

# If >85°C, investigate cooling:
# - Check physical vents not blocked
# - Clean dust from GPU
# - Improve case airflow
# - Reduce ambient temperature

# Temporary: Limit GPU usage (reduces performance)
# (Requires model reload with different parameters)
```

#### Out of Disk Space

```powershell
# Check disk usage
Get-PSDrive C | Select-Object Used,Free

# Free up space:
# 1. Clean Windows temp
Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue

# 2. Remove old log archives
Remove-Item "C:\LogArchives\*" -Force

# 3. Remove unused models
ollama list
ollama rm unused-model
```

### 7.2 Emergency Procedures

#### Complete System Failure

1. **Reboot server**
2. **Verify GPU detected**: `nvidia-smi`
3. **Restore from backup** (see section 5.3)
4. **Test with small model first**: `ollama run qwen-14b-cline "test"`
5. **If working, load full models**

#### GPU Hardware Failure

1. **Replace GPU with equivalent model** (24GB+ VRAM)
2. **Install NVIDIA drivers**
3. **Restore configuration**
4. **Test inference**

## 8. Monitoring Scripts

### 8.1 Automated Daily Health Check

Create scheduled task:

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-File C:\AirGapInstall\scripts\health-check.ps1 | Out-File C:\HealthCheckLogs\check-$(Get-Date -Format 'yyyy-MM-dd').log"

$trigger = New-ScheduledTaskTrigger -Daily -At "8:00AM"

Register-ScheduledTask -TaskName "AirGapAICoder-HealthCheck" `
    -Action $action `
    -Trigger $trigger
```

### 8.2 Performance Logging

Create continuous monitoring script: `scripts\monitor-performance.ps1`

```powershell
while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # GPU stats
    $gpuUtil = nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits
    $vramUsed = nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits
    $temp = nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits

    # Process stats
    $ollamaProc = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
    $cpuUsage = $ollamaProc.CPU
    $memUsage = [math]::Round($ollamaProc.WS / 1GB, 2)

    # Log to CSV
    "$timestamp,$gpuUtil,$vramUsed,$temp,$cpuUsage,$memUsage" |
        Out-File "C:\PerformanceLogs\perf-$(Get-Date -Format 'yyyy-MM-dd').csv" -Append

    Start-Sleep -Seconds 60
}
```

---

**Document Control**:
- **Location**: `/docs/OPERATIONS.md`
- **Maintained by**: Operations Team
- **Review Frequency**: Monthly or after incidents
