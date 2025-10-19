#!/usr/bin/env powershell
# Uninstall AirAI CLI from Windows
# Part of AirGapAICoder project
# Author: Fuzemobi, LLC - Chad Rosenbohm

[CmdletBinding()]
param(
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

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  AirAI CLI - Uninstallation for Windows" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-StatusMessage "Uninstalling AirAI CLI..."

try {
    & $PythonPath -m pip uninstall airai -y

    if ($LASTEXITCODE -eq 0) {
        Write-StatusMessage "AirAI CLI uninstalled successfully!" "Success"
        Write-Host ""
        Write-StatusMessage "To reinstall, run: .\install-airai-windows.ps1" "Info"
        Write-Host ""
        exit 0
    } else {
        Write-StatusMessage "Uninstallation failed with exit code $LASTEXITCODE" "Error"
        exit 1
    }
} catch {
    Write-StatusMessage "Uninstallation error: $($_.Exception.Message)" "Error"
    exit 1
}
