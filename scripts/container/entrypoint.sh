#!/bin/bash
# Entrypoint script for AirGapAICoder container
# Version: 1.2.0
# Author: Fuzemobi, LLC - Chad Rosenbohm

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Display startup banner
display_banner() {
    echo "======================================================="
    echo "  AirGapAICoder - AI Coding Assistant"
    echo "  Version: $(cat /VERSION 2>/dev/null || echo '1.2.0')"
    echo "  Author: Fuzemobi, LLC - Chad Rosenbohm"
    echo "======================================================="
    echo ""
}

# Check GPU availability
check_gpu() {
    log_info "Checking GPU availability..."

    if command -v nvidia-smi &> /dev/null; then
        if nvidia-smi &> /dev/null; then
            log_success "GPU detected:"
            nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | \
                awk '{printf "  - %s (%.0f GB VRAM)\n", $1, $2/1024}'
        else
            log_warning "nvidia-smi found but GPU not accessible"
            log_warning "Container may not have GPU access configured"
        fi
    else
        log_warning "nvidia-smi not found - GPU acceleration disabled"
        log_warning "For GPU support, ensure NVIDIA Container Toolkit is installed"
    fi
}

# Verify Ollama installation
verify_ollama() {
    log_info "Verifying Ollama installation..."

    if command -v ollama &> /dev/null; then
        local version=$(ollama --version 2>&1 | head -n 1)
        log_success "Ollama installed: $version"
    else
        log_error "Ollama not found!"
        exit 1
    fi
}

# Verify AirAI CLI
verify_airai() {
    log_info "Verifying AirAI CLI..."

    if command -v airai &> /dev/null; then
        local version=$(airai --version 2>&1 | head -n 1)
        log_success "AirAI CLI installed: $version"
    else
        log_warning "AirAI CLI not found (optional component)"
    fi
}

# Create necessary directories
setup_directories() {
    log_info "Setting up directories..."

    mkdir -p /root/.ollama/models
    mkdir -p /var/log/ollama
    mkdir -p /tmp/ollama

    chmod 755 /root/.ollama
    chmod 755 /var/log/ollama

    log_success "Directories configured"
}

# Display configuration
display_config() {
    echo ""
    log_info "Configuration:"
    echo "  OLLAMA_HOST: ${OLLAMA_HOST:-0.0.0.0:11434}"
    echo "  OLLAMA_NUM_PARALLEL: ${OLLAMA_NUM_PARALLEL:-1}"
    echo "  OLLAMA_MAX_LOADED_MODELS: ${OLLAMA_MAX_LOADED_MODELS:-1}"
    echo "  OLLAMA_FLASH_ATTENTION: ${OLLAMA_FLASH_ATTENTION:-1}"
    echo "  OLLAMA_KEEP_ALIVE: ${OLLAMA_KEEP_ALIVE:-24h}"
    echo "  OLLAMA_MODELS: ${OLLAMA_MODELS:-/root/.ollama/models}"
    echo ""
}

# List available models (if any)
list_models() {
    log_info "Checking for available models..."

    if [ -d "${OLLAMA_MODELS:-/root/.ollama/models}" ]; then
        local model_count=$(find "${OLLAMA_MODELS}" -type f -name "*.bin" 2>/dev/null | wc -l || echo "0")

        if [ "$model_count" -gt 0 ]; then
            log_success "Found $model_count model file(s)"
        else
            log_warning "No models found in ${OLLAMA_MODELS}"
            log_info "Download models with: ollama pull <model-name>"
            log_info "Or mount pre-downloaded models as a volume"
        fi
    fi

    echo ""
}

# Start Ollama server
start_ollama() {
    log_info "Starting Ollama server on ${OLLAMA_HOST}..."
    echo ""

    # Execute Ollama serve with all output visible
    exec ollama serve
}

# Health check function (can be called externally)
health_check() {
    if curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Main entrypoint logic
main() {
    # Display banner
    display_banner

    # If command is "serve", do full initialization
    if [[ "$1" == "serve" ]]; then
        check_gpu
        verify_ollama
        verify_airai
        setup_directories
        display_config
        list_models
        start_ollama
    # If command is "health", run health check
    elif [[ "$1" == "health" ]]; then
        health_check
        exit $?
    # Otherwise, execute the provided command
    else
        exec "$@"
    fi
}

# Run main function with all arguments
main "$@"
