#!/usr/bin/env powershell
# Install AirAI CLI globally on Windows
# Part of AirGapAICoder project
# Author: Fuzemobi, LLC - Chad Rosenbohm

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Install from local wheel file instead of pip")]
    [string]$WheelPath,

    [Parameter(HelpMessage = "Python executable path")]
    [string]$PythonPath = "python"
)

$ErrorActionPreference = "Stop"

function Write-StatusMessage {
    param([string]$Message, [string]$Type = "Info")
    $colors = @{
        "Info" = "Cyan"
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error" = "Red"
    }
    Write-Host "[$Type] $Message" -ForegroundColor $colors[$Type]
}

function Test-PythonInstalled {
    Write-StatusMessage "Checking for Python installation..."
    try {
        $version = & $PythonPath --version 2>&1
        if ($version -match "Python (\d+)\.(\d+)") {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]

            if ($major -ge 3 -and $minor -ge 9) {
                Write-StatusMessage "Found Python $major.$minor" "Success"
                return $true
            } else {
                Write-StatusMessage "Python 3.9+ required (found $major.$minor)" "Error"
                return $false
            }
        }
    } catch {
        Write-StatusMessage "Python not found. Please install Python 3.9+ from python.org" "Error"
        return $false
    }
    return $false
}

function Test-PipInstalled {
    Write-StatusMessage "Checking for pip..."
    try {
        & $PythonPath -m pip --version | Out-Null
        Write-StatusMessage "pip is installed" "Success"
        return $true
    } catch {
        Write-StatusMessage "pip not found. Installing..." "Warning"
        try {
            & $PythonPath -m ensurepip --upgrade
            Write-StatusMessage "pip installed successfully" "Success"
            return $true
        } catch {
            Write-StatusMessage "Failed to install pip" "Error"
            return $false
        }
    }
}

function Install-AirAI {
    Write-StatusMessage "Installing AirAI CLI..."

    try {
        if ($WheelPath) {
            # Install from wheel file (air-gap deployment)
            if (-not (Test-Path $WheelPath)) {
                Write-StatusMessage "Wheel file not found: $WheelPath" "Error"
                return $false
            }
            Write-StatusMessage "Installing from wheel: $WheelPath"
            & $PythonPath -m pip install $WheelPath --no-index --force-reinstall
        } else {
            # Install from source (development)
            $projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
            Write-StatusMessage "Installing from source: $projectRoot"
            & $PythonPath -m pip install -e $projectRoot
        }

        if ($LASTEXITCODE -eq 0) {
            Write-StatusMessage "AirAI CLI installed successfully!" "Success"
            return $true
        } else {
            Write-StatusMessage "Installation failed with exit code $LASTEXITCODE" "Error"
            return $false
        }
    } catch {
        Write-StatusMessage "Installation error: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Test-AirAICommand {
    Write-StatusMessage "Verifying airai command..."

    try {
        # Refresh PATH for current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")

        $version = & airai --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-StatusMessage "✓ airai command is available: $version" "Success"
            return $true
        } else {
            Write-StatusMessage "airai command not found in PATH" "Warning"
            Write-StatusMessage "You may need to restart your terminal or add Python Scripts to PATH" "Warning"

            # Show where Python Scripts directory is
            $scriptsPath = & $PythonPath -c 'import sys, os; print(os.path.join(sys.prefix, "Scripts"))'
            Write-StatusMessage "Python Scripts location: $scriptsPath" "Info"

            return $false
        }
    } catch {
        Write-StatusMessage "Verification error: $($_.Exception.Message)" "Warning"
        return $false
    }
}

function Show-NextSteps {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  AirAI CLI Installation Complete!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart your terminal (or run: refreshenv)" -ForegroundColor White
    Write-Host "  2. Test installation: airai --version" -ForegroundColor White
    Write-Host "  3. Check server health: airai health" -ForegroundColor White
    Write-Host "  4. List models: airai models list" -ForegroundColor White
    Write-Host "  5. Get help: airai --help" -ForegroundColor White
    Write-Host ""
    Write-Host "Quick Examples:" -ForegroundColor Yellow
    Write-Host '  airai chat qwen-32b-cline "Write a Python function"' -ForegroundColor Cyan
    Write-Host "  airai code review src/" -ForegroundColor Cyan
    Write-Host '  airai code edit app.py "add error handling"' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Documentation: https://github.com/fuzemobi/AirGapAICoder" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

# Main installation flow
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  AirAI CLI - Global Installation for Windows" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Python
if (-not (Test-PythonInstalled)) {
    Write-StatusMessage "Please install Python 3.9+ from https://www.python.org/downloads/" "Error"
    Write-StatusMessage "Make sure to check 'Add Python to PATH' during installation" "Info"
    exit 1
}

# Step 2: Check pip
if (-not (Test-PipInstalled)) {
    Write-StatusMessage "Failed to install pip" "Error"
    exit 1
}

# Step 3: Install AirAI
if (-not (Install-AirAI)) {
    Write-StatusMessage "Installation failed" "Error"
    exit 1
}

# Step 4: Verify installation
$commandAvailable = Test-AirAICommand

# Step 5: Show next steps
Show-NextSteps

if ($commandAvailable) {
    exit 0
} else {
    Write-StatusMessage "Installation completed but command verification failed" "Warning"
    Write-StatusMessage "You may need to restart your terminal" "Warning"
    exit 0
}
