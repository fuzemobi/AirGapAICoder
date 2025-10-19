#!/bin/bash
# Export container for air-gap deployment

set -e

IMAGE_NAME="${IMAGE_NAME:-airgap-ollama}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/airgap-package/container}"
RUNTIME="${CONTAINER_RUNTIME:-podman}"

mkdir -p "$OUTPUT_DIR"

echo "Exporting container image to tar..."
$RUNTIME save -o "$OUTPUT_DIR/airgap-ollama-${IMAGE_TAG}.tar" "$IMAGE_NAME:$IMAGE_TAG"

echo "Creating deployment package..."
cat > "$OUTPUT_DIR/load-and-run.sh" << 'EOFLOAD'
#!/bin/bash
# Load and run AirGapAICoder container on air-gap system

set -e

RUNTIME="${CONTAINER_RUNTIME:-podman}"
IMAGE_TAR="airgap-ollama-latest.tar"

echo "Loading container image..."
$RUNTIME load -i "$IMAGE_TAR"

echo "Starting container..."
$RUNTIME run -d \
    --name airgap-ollama-server \
    --device nvidia.com/gpu=all \
    -p 11434:11434 \
    -v $HOME/.ollama/models:/root/.ollama/models:Z \
    airgap-ollama:latest

echo ""
echo "✓ Container started!"
echo "  Ollama API: http://localhost:11434"
echo ""
echo "Test connection:"
echo "  curl http://localhost:11434/api/tags"
EOFLOAD

chmod +x "$OUTPUT_DIR/load-and-run.sh"

echo ""
echo "✓ Air-gap package created at: $OUTPUT_DIR"
echo ""
ls -lh "$OUTPUT_DIR"
echo ""
echo "Transfer this directory to the air-gap system and run:"
echo "  ./load-and-run.sh"
