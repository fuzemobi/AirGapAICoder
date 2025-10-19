#!/usr/bin/env bash
# Uninstall AirAI CLI from macOS/Linux
# Part of AirGapAICoder project
# Author: Fuzemobi, LLC - Chad Rosenbohm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PYTHON_CMD="${PYTHON_CMD:-python3}"

print_status() {
    echo -e "${CYAN}[Info]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Success]${NC} $1"
}

print_error() {
    echo -e "${RED}[Error]${NC} $1"
}

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  AirAI CLI - Uninstallation for macOS/Linux"
echo "═══════════════════════════════════════════════════════"
echo ""

print_status "Uninstalling AirAI CLI..."

if $PYTHON_CMD -m pip uninstall airai -y; then
    print_success "AirAI CLI uninstalled successfully!"
    echo ""
    print_status "To reinstall, run: ./install-airai.sh"
    echo ""
    exit 0
else
    print_error "Uninstallation failed"
    exit 1
fi
