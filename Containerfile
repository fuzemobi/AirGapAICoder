# Containerfile for AirGapAICoder
# Podman-compatible (also works with Docker)

FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

LABEL maintainer="Fuzemobi, LLC - Chad Rosenbohm"
LABEL description="AirGapAICoder - Air-gapped AI coding assistant with Ollama"
LABEL version="1.1.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_FLASH_ATTENTION=1
ENV OLLAMA_MODELS=/root/.ollama/models

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Create directories
RUN mkdir -p /root/.ollama/models

# Install AirAI CLI (if wheel exists in dist/)
# This will be copied during build
COPY pyproject.toml /tmp/
COPY src/ /tmp/src/
RUN cd /tmp && pip3 install --no-cache-dir -e . && rm -rf /tmp/src /tmp/pyproject.toml

# Expose Ollama API port
EXPOSE 11434

# Volume for model persistence
VOLUME ["/root/.ollama/models"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:11434/api/tags || exit 1

# Copy entrypoint script
COPY scripts/container/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["serve"]
