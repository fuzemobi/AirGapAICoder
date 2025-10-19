#!/bin/bash
#================================================================
# AirGapAICoder - Preparation Script (Unix: macOS/Linux)
# Downloads all required components for air-gap deployment
# Run this script on an internet-connected system
#
# Author: Fuzemobi, LLC - Chad Rosenbohm
# Usage: ./pull-all.sh [download_directory]
#================================================================

set -eo pipefail  # Exit on error, pipe failures

# Configuration
DOWNLOAD_DIR="${1:-$HOME/airgap-package}"
LOG_FILE="$DOWNLOAD_DIR/pull.log"
MANIFEST_FILE="$DOWNLOAD_DIR/MANIFEST.txt"

# Model configuration
MODELS=(
    "qwen2.5-coder:32b-instruct-fp16"
    "deepseek-r1:32b"
    "qwen2.5-coder:14b"
)

# Test model for validation (small size)
TEST_MODEL="qwen:0.5b"

# Colors for output
RED='\033[0.31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        *)          echo "unknown" ;;
    esac
}

check_prerequisites() {
    log "Checking prerequisites..."

    local missing=()

    command -v curl >/dev/null 2>&1 || missing+=("curl")
    command -v shasum >/dev/null 2>&1 || command -v sha256sum >/dev/null 2>&1 || missing+=("shasum/sha256sum")

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing[*]}"
        log_error "Please install: ${missing[*]}"
        exit 1
    fi

    log_success "All prerequisites met"
}

create_directory_structure() {
    log "Creating directory structure..."

    mkdir -p "$DOWNLOAD_DIR"/{installers,models,extensions,config,scripts,docs}
    mkdir -p "$DOWNLOAD_DIR"/config/modelfiles

    log_success "Directory structure created at: $DOWNLOAD_DIR"
}

download_ollama() {
    log "Downloading Ollama..."

    local platform=$(detect_platform)
    local download_url
    local output_file

    case "$platform" in
        macos)
            download_url="https://ollama.com/download/Ollama-darwin.zip"
            output_file="$DOWNLOAD_DIR/installers/Ollama-darwin.zip"
            ;;
        linux)
            # Ollama provides a universal install script for Linux
            download_url="https://ollama.com/install.sh"
            output_file="$DOWNLOAD_DIR/installers/ollama-install.sh"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            return 1
            ;;
    esac

    if [ -f "$output_file" ]; then
        log_warning "Ollama installer already exists, skipping download"
        return 0
    fi

    if curl -L -o "$output_file" "$download_url"; then
        log_success "Ollama downloaded successfully"

        if [ "$platform" = "linux" ]; then
            chmod +x "$output_file"
        fi

        return 0
    else
        log_error "Failed to download Ollama"
        return 1
    fi
}

install_ollama_if_needed() {
    if command -v ollama >/dev/null 2>&1; then
        log_success "Ollama already installed: $(ollama --version)"
        return 0
    fi

    log "Ollama not found. Installing..."

    local platform=$(detect_platform)

    case "$platform" in
        macos)
            log "Please install Ollama manually from: https://ollama.com/download"
            log "Or run: brew install ollama"
            log "After installation, re-run this script to continue"
            exit 1
            ;;
        linux)
            if [ -f "$DOWNLOAD_DIR/installers/ollama-install.sh" ]; then
                sudo bash "$DOWNLOAD_DIR/installers/ollama-install.sh"
            else
                curl -fsSL https://ollama.com/install.sh | sudo sh
            fi
            ;;
    esac

    if command -v ollama >/dev/null 2>&1; then
        log_success "Ollama installed successfully"
        return 0
    else
        log_error "Ollama installation failed"
        return 1
    fi
}

pull_models() {
    log "Pulling AI models (this may take a while)..."

    if ! command -v ollama >/dev/null 2>&1; then
        log_error "Ollama is not installed. Cannot pull models."
        return 1
    fi

    # Start Ollama service if not running
    if ! pgrep -x "ollama" > /dev/null; then
        log "Starting Ollama service..."
        ollama serve &
        sleep 3
    fi

    local pull_production=${PULL_PRODUCTION_MODELS:-false}

    if [ "$pull_production" = "true" ]; then
        # Pull full production models (large downloads)
        for model in "${MODELS[@]}"; do
            log "Pulling model: $model (this may take 30-60 minutes)..."
            if ollama pull "$model"; then
                log_success "Model pulled: $model"
            else
                log_error "Failed to pull model: $model"
            fi
        done
    else
        # Pull only test model for validation
        log_warning "Pulling test model only ($TEST_MODEL)"
        log "To pull production models, set: export PULL_PRODUCTION_MODELS=true"
        log "Production models are large (~19GB each):"
        for model in "${MODELS[@]}"; do
            log "  - $model"
        done
        echo

        log "Pulling test model: $TEST_MODEL (~300MB)..."
        if ollama pull "$TEST_MODEL"; then
            log_success "Test model pulled: $TEST_MODEL"
        else
            log_error "Failed to pull test model"
            return 1
        fi
    fi
}

package_models() {
    log "Packaging Ollama models..."

    local ollama_models_dir
    case "$(detect_platform)" in
        macos)
            ollama_models_dir="$HOME/.ollama/models"
            ;;
        linux)
            ollama_models_dir="$HOME/.ollama/models"
            ;;
    esac

    if [ ! -d "$ollama_models_dir" ]; then
        log_error "Ollama models directory not found: $ollama_models_dir"
        return 1
    fi

    log "Copying models from $ollama_models_dir..."
    cp -r "$ollama_models_dir"/* "$DOWNLOAD_DIR/models/" 2>/dev/null || {
        # If no models found, that's okay if we're in test mode
        log_warning "No models found to copy (this is normal for test runs)"
    }

    log_success "Models packaged"
}

download_vscode() {
    log "VS Code download instructions..."
    log_warning "VS Code must be downloaded manually from:"
    log "  https://code.visualstudio.com/download"
    log "Save to: $DOWNLOAD_DIR/installers/"
    echo
}

download_cline() {
    log "Downloading Cline extension..."

    local ext_url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/saoudrizwan/vsextensions/claude-dev/latest/vspackage"
    local output_file="$DOWNLOAD_DIR/extensions/cline.vsix"

    mkdir -p "$DOWNLOAD_DIR/extensions"

    if [ -f "$output_file" ]; then
        log_warning "Cline extension already exists, skipping"
        return 0
    fi

    if curl -L -o "$output_file" "$ext_url"; then
        log_success "Cline extension downloaded"
        return 0
    else
        log_warning "Failed to download Cline extension"
        log "Please download manually from:"
        log "  https://marketplace.visualstudio.com/items?itemName=saoudrizwan.claude-dev"
        return 1
    fi
}

copy_config_files() {
    log "Copying configuration files..."

    # Copy modelfiles if they exist in the repo
    if [ -d "../../config/modelfiles" ]; then
        cp -r ../../config/modelfiles "$DOWNLOAD_DIR/config/"
        log_success "Modelfiles copied"
    fi

    # Copy cline config template
    if [ -f "../../config/cline/settings-template.json" ]; then
        mkdir -p "$DOWNLOAD_DIR/config/cline"
        cp ../../config/cline/settings-template.json "$DOWNLOAD_DIR/config/cline/"
        log_success "Cline config template copied"
    fi
}

generate_manifest() {
    log "Generating manifest..."

    cat > "$MANIFEST_FILE" << EOF
================================================================
AIRGAPAICODER INSTALLATION PACKAGE
================================================================

Generated: $(date)
Platform: $(detect_platform)
Generated by: $(whoami)@$(hostname)

CONTENTS:
=========

installers/
  - Ollama installer for $(detect_platform)
  $([ -f "$DOWNLOAD_DIR/installers/VSCode"* ] && echo "- VS Code installer" || echo "- VS Code (download manually)")

models/
  - Ollama model files
  $(ollama list 2>/dev/null | tail -n +2 | awk '{print "  -", $1}')

extensions/
  $([ -f "$DOWNLOAD_DIR/extensions/cline.vsix" ] && echo "- Cline extension (.vsix)" || echo "- Cline extension (download manually)")

config/
  - Modelfiles for extended context
  - Cline configuration templates

INSTALLATION:
=============

1. Transfer this entire directory to the air-gapped server
2. Follow SERVER-SETUP.md for installation instructions
3. For clients, see CLIENT-USAGE.md

PACKAGE SIZE:
=============

Total: $(du -sh "$DOWNLOAD_DIR" | cut -f1)

$(find "$DOWNLOAD_DIR" -type f -name "*.zip" -o -name "*.vsix" -o -name "*.sh" | while read file; do
    echo "  $(basename "$file"): $(du -h "$file" | cut -f1)"
done)

CHECKSUMS:
==========

$(find "$DOWNLOAD_DIR" -type f \( -name "*.zip" -o -name "*.vsix" -o -name "*.sh" \) -exec shasum -a 256 {} \; 2>/dev/null)

================================================================
END OF MANIFEST
================================================================
EOF

    log_success "Manifest generated: $MANIFEST_FILE"
}

create_readme() {
    cat > "$DOWNLOAD_DIR/README.txt" << EOF
AIRGAPAICODER INSTALLATION PACKAGE
===================================

This package contains all components needed to deploy AirGapAICoder
in an air-gapped environment.

QUICK START:
------------

1. Review MANIFEST.txt for package contents
2. Transfer entire directory to target server (USB/removable media)
3. Follow installation guides in docs/

INSTALLATION GUIDES:
--------------------

- docs/SERVER-SETUP.md: Complete server installation guide
- docs/CLIENT-USAGE.md: Client workstation setup
- docs/CLI-REFERENCE.md: Remote management commands

SUPPORT:
--------

For issues or questions, see documentation in the docs/ directory
or visit: https://github.com/fuzemobi/AirGapAICoder

Generated: $(date)
EOF

    log_success "README created"
}

#================================================================
# Main Execution
#================================================================

main() {
    echo "================================================================"
    echo "  AirGapAICoder - Preparation Script"
    echo "  Platform: $(detect_platform)"
    echo "================================================================"
    echo

    check_prerequisites
    create_directory_structure

    download_ollama
    install_ollama_if_needed
    pull_models
    package_models

    download_vscode
    download_cline

    copy_config_files
    generate_manifest
    create_readme

    echo
    echo "================================================================"
    log_success "Preparation complete!"
    echo "================================================================"
    echo
    echo "Package location: $DOWNLOAD_DIR"
    echo "Package size: $(du -sh "$DOWNLOAD_DIR" | cut -f1)"
    echo
    echo "Next steps:"
    echo "  1. Review $MANIFEST_FILE"
    echo "  2. Manually download VS Code if not done"
    echo "  3. Transfer package to air-gapped server"
    echo "  4. Follow SERVER-SETUP.md for installation"
    echo

    if [ "$PULL_PRODUCTION_MODELS" != "true" ]; then
        echo "NOTE: Only test model was downloaded"
        echo "To download production models (47GB), run:"
        echo "  export PULL_PRODUCTION_MODELS=true"
        echo "  ./pull-all.sh"
        echo
    fi
}

# Run main function
main "$@"
