#!/bin/bash
# Run the AirGapAICoder container

set -e

# Configuration
IMAGE_NAME="${IMAGE_NAME:-airgap-ollama}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-airgap-ollama-server}"
RUNTIME="${CONTAINER_RUNTIME:-podman}"
PORT="${OLLAMA_PORT:-11434}"
MODELS_DIR="${MODELS_DIR:-$HOME/.ollama/models}"

# Create models directory if it doesn't exist
mkdir -p "$MODELS_DIR"

# Check if container already exists
if $RUNTIME ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container $CONTAINER_NAME already exists. Starting..."
    $RUNTIME start "$CONTAINER_NAME"
    exit 0
fi

echo "Starting AirGapAICoder container..."
$RUNTIME run -d \
    --name "$CONTAINER_NAME" \
    --device nvidia.com/gpu=all \
    -p "$PORT:11434" \
    -v "$MODELS_DIR:/root/.ollama/models:Z" \
    -e OLLAMA_HOST=0.0.0.0:11434 \
    "$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo "✓ Container started: $CONTAINER_NAME"
echo "  Ollama API: http://localhost:$PORT"
echo ""
echo "Commands:"
echo "  Check status:  $RUNTIME ps"
echo "  View logs:     $RUNTIME logs -f $CONTAINER_NAME"
echo "  Test API:      curl http://localhost:$PORT/api/tags"
