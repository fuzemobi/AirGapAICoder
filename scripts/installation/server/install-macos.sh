#!/bin/bash
#================================================================
# AirGapAICoder - Server Installation Script (macOS)
# For local testing and development purposes
#
# Author: Fuzemobi, LLC - Chad Rosenbohm
# Usage: sudo ./install-macos.sh [package_directory]
#================================================================

set -eo pipefail

# Configuration
PACKAGE_DIR="${1:-$HOME/airgap-package}"
LOG_FILE="/tmp/airgap-install.log"
OLLAMA_SERVICE_PLIST="$HOME/Library/LaunchAgents/com.airgap.ollama.plist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

#================================================================
# Helper Functions
#================================================================

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is for macOS only"
        exit 1
    fi

    log_success "macOS detected: $(sw_vers -productVersion)"
}

check_disk_space() {
    log "Checking available disk space..."

    local available=$(df -g / | awk 'NR==2 {print $4}')
    local required=50

    if [ "$available" -lt "$required" ]; then
        log_error "Insufficient disk space: ${available}GB available, ${required}GB required"
        exit 1
    fi

    log_success "Disk space OK: ${available}GB available"
}

install_ollama() {
    log "Installing Ollama..."

    if command -v ollama >/dev/null 2>&1; then
        log_success "Ollama already installed: $(ollama --version)"
        return 0
    fi

    # Check if we have a local package
    if [ -f "$PACKAGE_DIR/installers/Ollama-darwin.zip" ]; then
        log "Installing from package..."
        unzip -q "$PACKAGE_DIR/installers/Ollama-darwin.zip" -d /tmp/
        cp -r /tmp/Ollama.app /Applications/
        log_success "Ollama installed from package"
    else
        log_warning "No local package found, installing via Homebrew..."
        if command -v brew >/dev/null 2>&1; then
            brew install ollama
            log_success "Ollama installed via Homebrew"
        else
            log_error "Homebrew not found. Please install Ollama manually:"
            log "  https://ollama.com/download"
            exit 1
        fi
    fi

    # Verify installation
    if command -v ollama >/dev/null 2>&1; then
        log_success "Ollama installation verified"
    else
        log_error "Ollama installation failed"
        exit 1
    fi
}

copy_models() {
    log "Copying AI models..."

    local models_src="$PACKAGE_DIR/models"
    local models_dest="$HOME/.ollama/models"

    if [ ! -d "$models_src" ] || [ -z "$(ls -A "$models_src" 2>/dev/null)" ]; then
        log_warning "No models found in package"
        log "You'll need to download models separately"
        return 0
    fi

    mkdir -p "$models_dest"

    log "Copying models (this may take a few minutes)..."
    cp -r "$models_src"/* "$models_dest/"

    log_success "Models copied to $models_dest"
}

configure_ollama() {
    log "Configuring Ollama..."

    # For macOS, environment variables can be set in LaunchAgent plist
    # or in shell profile

    # Add to shell profile
    local profile_file="$HOME/.zshrc"
    if [ ! -f "$profile_file" ]; then
        profile_file="$HOME/.bash_profile"
    fi

    if ! grep -q "OLLAMA_HOST" "$profile_file" 2>/dev/null; then
        cat >> "$profile_file" << 'EOF'

# AirGapAICoder Ollama Configuration
export OLLAMA_HOST="0.0.0.0:11434"
export OLLAMA_NUM_PARALLEL="1"
export OLLAMA_MAX_LOADED_MODELS="1"
export OLLAMA_FLASH_ATTENTION="1"
EOF
        log_success "Environment variables added to $profile_file"
    else
        log_warning "Ollama configuration already present in $profile_file"
    fi

    # Source the file
    source "$profile_file" 2>/dev/null || true

    log_success "Ollama configured"
}

create_launch_agent() {
    log "Creating LaunchAgent for automatic startup..."

    mkdir -p "$HOME/Library/LaunchAgents"

    cat > "$OLLAMA_SERVICE_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.airgap.ollama</string>

    <key>ProgramArguments</key>
    <array>
        <string>$(which ollama)</string>
        <string>serve</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>0.0.0.0:11434</string>
        <key>OLLAMA_NUM_PARALLEL</key>
        <string>1</string>
        <key>OLLAMA_MAX_LOADED_MODELS</key>
        <string>1</string>
        <key>OLLAMA_FLASH_ATTENTION</key>
        <string>1</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/ollama.log</string>

    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/ollama-error.log</string>
</dict>
</plist>
EOF

    log_success "LaunchAgent created: $OLLAMA_SERVICE_PLIST"
}

start_ollama_service() {
    log "Starting Ollama service..."

    # Load the LaunchAgent
    launchctl unload "$OLLAMA_SERVICE_PLIST" 2>/dev/null || true
    launchctl load "$OLLAMA_SERVICE_PLIST"

    sleep 3

    # Verify service is running
    if pgrep -x "ollama" > /dev/null; then
        log_success "Ollama service is running"
    else
        log_warning "Ollama service may not have started"
        log "Try starting manually: ollama serve"
    fi
}

verify_installation() {
    log "Verifying installation..."

    # Wait for service to be ready
    local max_attempts=10
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
            log_success "Ollama API is responding"
            break
        fi
        attempt=$((attempt + 1))
        log "Waiting for Ollama to be ready (attempt $attempt/$max_attempts)..."
        sleep 2
    done

    # Check models
    log "Checking available models..."
    if command -v ollama >/dev/null 2>&1; then
        ollama list || log_warning "Could not list models"
    fi

    # Get local IP
    local local_ip=$(ipconfig getifaddr en0 2>/dev/null || echo "N/A")

    log_success "Installation complete!"
    echo
    echo "=========================================="
    echo "  AirGapAICoder Server is Ready!"
    echo "=========================================="
    echo
    echo "Local access:  http://localhost:11434"
    echo "Network access: http://$local_ip:11434"
    echo
    echo "Test the server:"
    echo "  curl http://localhost:11434/api/tags"
    echo
    echo "List models:"
    echo "  ollama list"
    echo
    echo "Test inference:"
    echo "  ollama run qwen:0.5b 'Write a Python hello world'"
    echo
    echo "Logs:"
    echo "  tail -f $HOME/Library/Logs/ollama.log"
    echo
    echo "Stop service:"
    echo "  launchctl unload $OLLAMA_SERVICE_PLIST"
    echo
    echo "Start service:"
    echo "  launchctl load $OLLAMA_SERVICE_PLIST"
    echo
}

#================================================================
# Main Execution
#================================================================

main() {
    echo "================================================================"
    echo "  AirGapAICoder - Server Installation (macOS)"
    echo "================================================================"
    echo

    check_macos
    check_disk_space

    install_ollama
    copy_models
    configure_ollama
    create_launch_agent
    start_ollama_service
    verify_installation

    echo
    log_success "Server installation completed successfully!"
}

# Run main function
main "$@"
