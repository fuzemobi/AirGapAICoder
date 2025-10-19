#!/bin/bash
# Build the AirGapAICoder container image

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
IMAGE_NAME="${IMAGE_NAME:-airgap-ollama}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
RUNTIME="${CONTAINER_RUNTIME:-podman}"

echo "Building AirGapAICoder container image..."
echo "Image: $IMAGE_NAME:$IMAGE_TAG"
echo "Runtime: $RUNTIME"

cd "$PROJECT_ROOT"

$RUNTIME build \
    -t "$IMAGE_NAME:$IMAGE_TAG" \
    -f Containerfile \
    .

echo ""
echo "✓ Container image built successfully!"
echo ""
$RUNTIME images "$IMAGE_NAME:$IMAGE_TAG"
