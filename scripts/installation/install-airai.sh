#!/usr/bin/env bash
# Install AirAI CLI globally on macOS/Linux
# Part of AirGapAICoder project
# Author: Fuzemobi, LLC - Chad Rosenbohm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
WHEEL_PATH="${WHEEL_PATH:-}"
PYTHON_CMD="${PYTHON_CMD:-python3}"
MIN_PYTHON_MAJOR=3
MIN_PYTHON_MINOR=9

# Helper functions
print_status() {
    echo -e "${CYAN}[Info]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Success]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Warning]${NC} $1"
}

print_error() {
    echo -e "${RED}[Error]${NC} $1"
}

check_python() {
    print_status "Checking for Python installation..."

    if ! command -v "$PYTHON_CMD" &> /dev/null; then
        print_error "Python not found. Please install Python 3.9+ from python.org"
        echo ""
        echo "Installation instructions:"
        echo "  macOS:   brew install python@3.11"
        echo "  Ubuntu:  sudo apt-get install python3.11 python3-pip"
        echo "  Fedora:  sudo dnf install python3.11 python3-pip"
        return 1
    fi

    # Get Python version (compatible with both GNU and BSD sed)
    local version=$($PYTHON_CMD --version 2>&1 | sed -n 's/^Python \([0-9]*\.[0-9]*\).*/\1/p')
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)

    if [ "$major" -lt "$MIN_PYTHON_MAJOR" ] || \
       { [ "$major" -eq "$MIN_PYTHON_MAJOR" ] && [ "$minor" -lt "$MIN_PYTHON_MINOR" ]; }; then
        print_error "Python 3.9+ required (found $major.$minor)"
        return 1
    fi

    print_success "Found Python $major.$minor"
    return 0
}

check_pip() {
    print_status "Checking for pip..."

    if ! $PYTHON_CMD -m pip --version &> /dev/null; then
        print_warning "pip not found. Installing..."

        if $PYTHON_CMD -m ensurepip --upgrade &> /dev/null; then
            print_success "pip installed successfully"
            return 0
        else
            print_error "Failed to install pip"
            return 1
        fi
    fi

    print_success "pip is installed"
    return 0
}

install_airai() {
    print_status "Installing AirAI CLI..."

    # Detect if we're on macOS with externally-managed environment
    local pip_flags=""
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: Use --break-system-packages for Homebrew Python
        pip_flags="--break-system-packages"
        print_status "Detected macOS Homebrew Python - using --break-system-packages"
    fi

    if [ -n "$WHEEL_PATH" ]; then
        # Install from wheel file (air-gap deployment)
        if [ ! -f "$WHEEL_PATH" ]; then
            print_error "Wheel file not found: $WHEEL_PATH"
            return 1
        fi
        print_status "Installing from wheel: $WHEEL_PATH"
        $PYTHON_CMD -m pip install "$WHEEL_PATH" --no-index --force-reinstall $pip_flags
    else
        # Install from source (development)
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local project_root="$(cd "$script_dir/../.." && pwd)"
        print_status "Installing from source: $project_root"
        $PYTHON_CMD -m pip install -e "$project_root" $pip_flags
    fi

    if [ $? -eq 0 ]; then
        print_success "AirAI CLI installed successfully!"
        return 0
    else
        print_error "Installation failed"
        return 1
    fi
}

verify_command() {
    print_status "Verifying airai command..."

    # Refresh PATH for current session
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc" 2>/dev/null || true
    fi
    if [ -f "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc" 2>/dev/null || true
    fi

    # Try to find airai in common locations
    local airai_path=""
    if command -v airai &> /dev/null; then
        airai_path=$(command -v airai)
        local version=$(airai --version 2>&1)
        print_success "✓ airai command is available: $version"
        print_status "Location: $airai_path"
        return 0
    else
        print_warning "airai command not found in PATH"
        print_warning "You may need to restart your terminal or add Python bin to PATH"

        # Try to find where it was installed
        local python_bin=$($PYTHON_CMD -c "import sys, os; print(os.path.dirname(sys.executable))")
        print_status "Python bin location: $python_bin"

        # Check if airai exists there
        if [ -f "$python_bin/airai" ]; then
            print_status "Found airai at: $python_bin/airai"
            print_warning "Add this to your PATH: export PATH=\"$python_bin:\$PATH\""
        fi

        return 1
    fi
}

add_to_path_hint() {
    local python_bin=$($PYTHON_CMD -c "import sys, os; print(os.path.dirname(sys.executable))" 2>/dev/null || echo "")

    if [ -n "$python_bin" ]; then
        echo ""
        echo "To add airai to your PATH permanently, add this line to your shell config:"
        echo ""

        if [ "$(uname)" = "Darwin" ]; then
            # macOS
            if [ -n "$ZSH_VERSION" ]; then
                echo "  echo 'export PATH=\"$python_bin:\$PATH\"' >> ~/.zshrc"
                echo "  source ~/.zshrc"
            else
                echo "  echo 'export PATH=\"$python_bin:\$PATH\"' >> ~/.bash_profile"
                echo "  source ~/.bash_profile"
            fi
        else
            # Linux
            echo "  echo 'export PATH=\"$python_bin:\$PATH\"' >> ~/.bashrc"
            echo "  source ~/.bashrc"
        fi
        echo ""
    fi
}

show_next_steps() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo -e "  ${GREEN}AirAI CLI Installation Complete!${NC}"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Restart your terminal (or source your shell config)"
    echo "  2. Test installation: airai --version"
    echo "  3. Check server health: airai health"
    echo "  4. List models: airai models list"
    echo "  5. Get help: airai --help"
    echo ""
    echo -e "${YELLOW}Quick Examples:${NC}"
    echo -e "  ${CYAN}airai chat qwen-32b-cline \"Write a Python function\"${NC}"
    echo -e "  ${CYAN}airai code review src/${NC}"
    echo -e "  ${CYAN}airai code edit app.py \"add error handling\"${NC}"
    echo ""
    echo "Documentation: https://github.com/fuzemobi/AirGapAICoder"
    echo "═══════════════════════════════════════════════════════"
    echo ""
}

# Main installation flow
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  AirAI CLI - Global Installation for macOS/Linux"
echo "═══════════════════════════════════════════════════════"
echo ""

# Step 1: Check Python
if ! check_python; then
    exit 1
fi

# Step 2: Check pip
if ! check_pip; then
    exit 1
fi

# Step 3: Install AirAI
if ! install_airai; then
    print_error "Installation failed"
    exit 1
fi

# Step 4: Verify installation
if verify_command; then
    COMMAND_AVAILABLE=true
else
    COMMAND_AVAILABLE=false
    add_to_path_hint
fi

# Step 5: Show next steps
show_next_steps

if [ "$COMMAND_AVAILABLE" = true ]; then
    exit 0
else
    print_warning "Installation completed but command verification failed"
    print_warning "You may need to restart your terminal or update your PATH"
    exit 0
fi
