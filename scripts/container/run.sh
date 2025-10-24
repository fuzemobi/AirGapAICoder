#!/bin/bash
# Run the AirGapAICoder container
# Updated for v1.2.0 with enhanced Docker/Podman support

set -e

# Detect container runtime if not specified
detect_runtime() {
    if [ -n "$CONTAINER_RUNTIME" ]; then
        echo "$CONTAINER_RUNTIME"
    elif command -v docker &> /dev/null; then
        echo "docker"
    elif command -v podman &> /dev/null; then
        echo "podman"
    else
        echo "ERROR: Neither Docker nor Podman found!" >&2
        exit 1
    fi
}

# Configuration
IMAGE_NAME="${IMAGE_NAME:-airgap-ollama}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-airgap-ollama-server}"
RUNTIME=$(detect_runtime)
PORT="${OLLAMA_PORT:-11434}"
MODELS_DIR="${MODELS_DIR:-$HOME/.ollama/models}"
LOGS_DIR="${LOGS_DIR:-$HOME/.ollama/logs}"

# Create necessary directories
mkdir -p "$MODELS_DIR"
mkdir -p "$LOGS_DIR"

# Check if container already exists
if $RUNTIME ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container $CONTAINER_NAME already exists."
    read -p "Stop and remove it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $RUNTIME rm -f "$CONTAINER_NAME"
    else
        echo "Starting existing container..."
        $RUNTIME start "$CONTAINER_NAME"
        exit 0
    fi
fi

echo "Starting AirGapAICoder container..."
echo "  Runtime: $RUNTIME"
echo "  Image: $IMAGE_NAME:$IMAGE_TAG"
echo "  Port: $PORT"
echo "  Models: $MODELS_DIR"
echo ""

# Determine GPU device flag based on runtime
if [ "$RUNTIME" = "docker" ]; then
    GPU_FLAG="--gpus all"
else
    GPU_FLAG="--device nvidia.com/gpu=all"
fi

$RUNTIME run -d \
    --name "$CONTAINER_NAME" \
    $GPU_FLAG \
    -p "$PORT:11434" \
    -v "$MODELS_DIR:/root/.ollama/models:rw" \
    -v "$LOGS_DIR:/var/log/ollama:rw" \
    -e OLLAMA_HOST=0.0.0.0:11434 \
    -e OLLAMA_NUM_PARALLEL=${OLLAMA_NUM_PARALLEL:-1} \
    -e OLLAMA_MAX_LOADED_MODELS=${OLLAMA_MAX_LOADED_MODELS:-1} \
    -e OLLAMA_FLASH_ATTENTION=${OLLAMA_FLASH_ATTENTION:-1} \
    --restart unless-stopped \
    "$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo "✓ Container started: $CONTAINER_NAME"
echo "  Ollama API: http://localhost:$PORT"
echo "  Models directory: $MODELS_DIR"
echo "  Logs directory: $LOGS_DIR"
echo ""
echo "Useful commands:"
echo "  Check status:    $RUNTIME ps"
echo "  View logs:       $RUNTIME logs -f $CONTAINER_NAME"
echo "  Test API:        curl http://localhost:$PORT/api/tags"
echo "  List models:     $RUNTIME exec $CONTAINER_NAME ollama list"
echo "  Stop container:  $RUNTIME stop $CONTAINER_NAME"
echo "  Remove container: $RUNTIME rm -f $CONTAINER_NAME"
echo ""
echo "Or use Docker Compose for easier management:"
echo "  docker-compose up -d"
echo ""
