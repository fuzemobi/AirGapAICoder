# Containerfile for AirGapAICoder
# Multi-stage build for optimized image size and security
# Compatible with both Podman and Docker

# =============================================================================
# Stage 1: Base image with CUDA runtime
# =============================================================================
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04 AS base

LABEL maintainer="Fuzemobi, LLC - Chad Rosenbohm"
LABEL description="AirGapAICoder - Air-gapped AI coding assistant with Ollama"
LABEL version="1.2.0"
LABEL org.opencontainers.image.source="https://github.com/fuzemobi/AirGapAICoder"
LABEL org.opencontainers.image.licenses="MIT"

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies in a single layer to minimize image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# =============================================================================
# Stage 2: Ollama installation
# =============================================================================
FROM base AS ollama-installer

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Verify Ollama installation
RUN ollama --version

# =============================================================================
# Stage 3: AirAI CLI installation
# =============================================================================
FROM ollama-installer AS airai-installer

# Create working directory for installation
WORKDIR /tmp/airai-build

# Copy only necessary files for Python package installation
COPY pyproject.toml ./
COPY src/ ./src/
COPY VERSION ./
COPY LICENSE ./
COPY CHANGELOG.md ./

# Upgrade pip and install AirAI CLI
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install -e . && \
    airai --version

# =============================================================================
# Stage 4: Final runtime image
# =============================================================================
FROM ollama-installer AS runtime

# Copy AirAI CLI from build stage
COPY --from=airai-installer /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=airai-installer /usr/local/bin/airai /usr/local/bin/airai

# Set Ollama environment variables
ENV OLLAMA_HOST=0.0.0.0:11434 \
    OLLAMA_ORIGINS=* \
    OLLAMA_NUM_PARALLEL=1 \
    OLLAMA_MAX_LOADED_MODELS=1 \
    OLLAMA_FLASH_ATTENTION=1 \
    OLLAMA_MODELS=/root/.ollama/models \
    OLLAMA_KEEP_ALIVE=24h

# Create necessary directories with proper permissions
RUN mkdir -p /root/.ollama/models \
             /var/log/ollama \
             /etc/ollama && \
    chmod 755 /root/.ollama && \
    chmod 755 /var/log/ollama

# Copy configuration files
COPY config/modelfiles/ /etc/ollama/modelfiles/

# Copy and set up entrypoint script
COPY scripts/container/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose Ollama API port
EXPOSE 11434

# Create volume mount points
VOLUME ["/root/.ollama/models", "/var/log/ollama"]

# Health check to ensure Ollama is responsive
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:11434/api/tags || exit 1

# Set working directory
WORKDIR /root

# Use entrypoint script for initialization
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command: start Ollama server
CMD ["serve"]

# =============================================================================
# Build metadata
# =============================================================================
# Build with: docker build -t airgap-ollama:latest .
# Run with:   docker run -d --gpus all -p 11434:11434 airgap-ollama:latest
# Or use docker-compose.yml for easier deployment
