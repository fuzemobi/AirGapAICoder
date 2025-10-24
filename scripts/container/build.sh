#!/bin/bash
# Build the AirGapAICoder container image
# Updated for v1.2.0 with enhanced Docker/Podman support

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
RUNTIME=$(detect_runtime)

echo "Building AirGapAICoder container image..."
echo "Image: $IMAGE_NAME:$IMAGE_TAG"
echo "Runtime: $RUNTIME"
echo ""

cd "$PROJECT_ROOT"

$RUNTIME build \
    -t "$IMAGE_NAME:$IMAGE_TAG" \
    -f Containerfile \
    .

echo ""
echo "✓ Container image built successfully!"
echo ""
$RUNTIME images "$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo "Next steps:"
echo "  Test image:      ./scripts/docker/test-container.sh"
echo "  Run with compose: docker-compose up -d"
echo "  Export for air-gap: ./scripts/docker/export-airgap.sh"
echo ""
