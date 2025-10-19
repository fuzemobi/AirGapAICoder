#!/usr/bin/env powershell
# Installer script version: 2025-10-19 v3
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

# Ensure script can run even under restrictive policies (current process only)
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force | Out-Null
} catch {
    # Non-fatal; continue
}

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

# Helper: validate Python version string 'Python X.Y'
function Test-VersionOK {
    param([string]$ver)
    if ($ver -match "Python (\d+)\.(\d+)") {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        if (($major -gt 3) -or ($major -eq 3 -and $minor -ge 9)) {
            Write-StatusMessage "Found Python $major.$minor" "Success"
            return $true
        } else {
            Write-StatusMessage "Python 3.9+ required (found $major.$minor)" "Error"
            return $false
        }
    }
    return $false
}

function Test-PythonInstalled {
    Write-StatusMessage "Checking for Python installation..."


    # First try provided PythonPath
    try {
        $version = & $PythonPath --version 2>&1
        if (Test-VersionOK $version) { return $true }
    } catch {}

    # Fallback: use Python launcher if available
    try {
        $version = & py -3 --version 2>&1
        if (Test-VersionOK $version) {
            $script:PythonPath = "py"
            Write-StatusMessage "Using Python via Windows launcher: py -3" "Info"
            return $true
        }
    } catch {}

    Write-StatusMessage "Python not found. Please install Python 3.9+ from https://www.python.org/downloads/" "Error"
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

function Ensure-Toolchain {
    Write-StatusMessage "Upgrading pip/setuptools/wheel..."
    try {
        $code = Invoke-PipInstall @("install", "--upgrade", "pip", "setuptools", "wheel")
        if ($code -eq 0) {
            Write-StatusMessage "Toolchain up-to-date" "Success"
            return $true
        } else {
            Write-StatusMessage "Toolchain upgrade returned exit code $code (continuing)" "Warning"
            return $false
        }
    } catch {
        Write-StatusMessage "Toolchain upgrade error: $($_.Exception.Message) (continuing)" "Warning"
        return $false
    }
}

function Invoke-PipInstall {
    param([string[]]$Args)
    try {
        $null = & $PythonPath -m pip @Args
        if ($LASTEXITCODE -eq 0) { return 0 }
        if ($Args -notcontains "--user") {
            Write-StatusMessage "Retrying install with --user (no admin required)..." "Warning"
            $null = & $PythonPath -m pip @Args --user
            return $LASTEXITCODE
        } else {
            return $LASTEXITCODE
        }
    } catch {
        if ($Args -notcontains "--user") {
            Write-StatusMessage "Initial install failed: $($_.Exception.Message). Retrying with --user..." "Warning"
            $null = & $PythonPath -m pip @Args --user
            return $LASTEXITCODE
        } else {
            Write-StatusMessage "Install error: $($_.Exception.Message)" "Error"
            return 1
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
            $resolvedWheel = (Resolve-Path -LiteralPath $WheelPath).Path
            Write-StatusMessage "Installing from wheel: $resolvedWheel"
            $exitCode = Invoke-PipInstall @("install", $resolvedWheel, "--no-index", "--force-reinstall")
        } else {
            # Install from source (development)
            $projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
            Write-StatusMessage "Installing from source: $projectRoot"
            $exitCode = Invoke-PipInstall @("install", "-e", $projectRoot)
        }

        if ($exitCode -eq 0) {
            Write-StatusMessage "AirAI CLI installed successfully!" "Success"
            return $true
        } else {
            Write-StatusMessage "Installation failed with exit code $exitCode" "Error"
            return $false
        }
    } catch {
        Write-StatusMessage "Installation error: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Test-AirAICommand {
    Write-StatusMessage "Verifying airai command..."

    # Refresh PATH for current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")

    # First, see if the 'airai' shim exists on PATH without throwing
    $airaiCmd = $null
    try { $airaiCmd = Get-Command airai -ErrorAction SilentlyContinue } catch {}

    if ($airaiCmd) {
        try {
            $version = & airai --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-StatusMessage "✓ airai command is available: $version" "Success"
                return $true
            }
        } catch {
            # Fall through to module check
        }
    }

    # Try module execution as a fallback (works even if PATH not updated)
    try {
        $version2 = & $PythonPath -m airai --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-StatusMessage "✓ AirAI is installed: $version2" "Success"
            Write-StatusMessage "airai command not yet on PATH. You may need to restart your terminal or add Python Scripts to PATH" "Warning"

            # Show where Python Scripts directory is
            $scriptsPath = & $PythonPath -c 'import sys, os; print(os.path.join(sys.prefix, "Scripts"))'
            $userScriptsPath = & $PythonPath -c 'import site, os; p=site.getusersitepackages(); print(os.path.join(os.path.dirname(p), "Scripts"))'
            Write-StatusMessage "Python Scripts (system): $scriptsPath" "Info"
            Write-StatusMessage "Python Scripts (user --user): $userScriptsPath" "Info"
            return $true
        }
    } catch {
        # ignore and proceed to info output below
    }

    Write-StatusMessage "airai command not found and module execution failed" "Warning"

    # Show where Python Scripts directory is
    $scriptsPath = & $PythonPath -c 'import sys, os; print(os.path.join(sys.prefix, "Scripts"))'
    $userScriptsPath = & $PythonPath -c 'import site, os; p=site.getusersitepackages(); print(os.path.join(os.path.dirname(p), "Scripts"))'
    Write-StatusMessage "Python Scripts (system): $scriptsPath" "Info"
    Write-StatusMessage "Python Scripts (user --user): $userScriptsPath" "Info"
    return $false
}

function Show-NextSteps {
    Write-Host ""
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "  AirAI CLI Installation Complete!" -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Cyan
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
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  AirAI CLI - Global Installation for Windows" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# Ensure we run from the installer directory (working directory change)
Push-Location -Path $PSScriptRoot
try {
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

    # Step 2.5: Ensure base toolchain is up to date (non-fatal)
    Ensure-Toolchain | Out-Null

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
}
finally {
    Pop-Location
}
