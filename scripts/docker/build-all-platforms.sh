#!/bin/bash
# Build AirGapAICoder container images for multiple platforms
# Version: 1.2.0
# Author: Fuzemobi, LLC - Chad Rosenbohm

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
IMAGE_NAME="${IMAGE_NAME:-airgap-ollama}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PLATFORMS="${PLATFORMS:-linux/amd64}"  # Default to amd64, can add linux/arm64 if needed
BUILD_ARGS="${BUILD_ARGS:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
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

detect_container_runtime() {
    if command -v docker &> /dev/null; then
        echo "docker"
    elif command -v podman &> /dev/null; then
        echo "podman"
    else
        log_error "Neither Docker nor Podman found. Please install one."
        exit 1
    fi
}

check_buildx() {
    local runtime=$1
    if [ "$runtime" = "docker" ]; then
        if ! docker buildx version &> /dev/null; then
            log_warning "Docker Buildx not found. Installing..."
            docker buildx install || {
                log_error "Failed to install Docker Buildx"
                return 1
            }
        fi

        # Create builder if needed
        if ! docker buildx inspect multiplatform &> /dev/null; then
            log_info "Creating multi-platform builder..."
            docker buildx create --name multiplatform --use || {
                log_error "Failed to create builder"
                return 1
            }
        else
            docker buildx use multiplatform
        fi
    fi
    return 0
}

build_image() {
    local runtime=$1

    log_info "Building AirGapAICoder container image..."
    log_info "  Runtime: $runtime"
    log_info "  Image: $IMAGE_NAME:$IMAGE_TAG"
    log_info "  Platforms: $PLATFORMS"

    cd "$PROJECT_ROOT"

    if [ "$runtime" = "docker" ] && [ "$PLATFORMS" != "linux/amd64" ]; then
        # Multi-platform build with Docker Buildx
        log_info "Using Docker Buildx for multi-platform build..."

        docker buildx build \
            --platform "$PLATFORMS" \
            -t "$IMAGE_NAME:$IMAGE_TAG" \
            -f Containerfile \
            $BUILD_ARGS \
            --load \
            .
    else
        # Standard build (Podman or single-platform Docker)
        $runtime build \
            -t "$IMAGE_NAME:$IMAGE_TAG" \
            -f Containerfile \
            $BUILD_ARGS \
            .
    fi

    if [ $? -eq 0 ]; then
        log_success "Container image built successfully!"
    else
        log_error "Container build failed!"
        exit 1
    fi
}

display_image_info() {
    local runtime=$1

    echo ""
    log_info "Image information:"
    $runtime images "$IMAGE_NAME:$IMAGE_TAG"

    echo ""
    log_info "Image size:"
    $runtime inspect "$IMAGE_NAME:$IMAGE_TAG" --format='{{.Size}}' | \
        awk '{printf "%.2f MB\n", $1/1024/1024}'
}

run_basic_test() {
    local runtime=$1

    echo ""
    log_info "Running basic container test..."

    # Test container starts
    if $runtime run --rm "$IMAGE_NAME:$IMAGE_TAG" ollama --version; then
        log_success "Container test passed!"
    else
        log_error "Container test failed!"
        return 1
    fi
}

# Main execution
main() {
    echo "======================================================="
    echo "  AirGapAICoder - Multi-Platform Container Build"
    echo "======================================================="
    echo ""

    # Detect container runtime
    RUNTIME=$(detect_container_runtime)
    log_info "Detected container runtime: $RUNTIME"

    # Check for buildx if using Docker with multiple platforms
    if [ "$RUNTIME" = "docker" ]; then
        check_buildx "$RUNTIME"
    fi

    # Build the image
    build_image "$RUNTIME"

    # Display image info
    display_image_info "$RUNTIME"

    # Run basic test
    run_basic_test "$RUNTIME"

    echo ""
    echo "======================================================="
    log_success "Build complete!"
    echo "======================================================="
    echo ""
    echo "Next steps:"
    echo "  1. Test the image:     ./scripts/docker/test-container.sh"
    echo "  2. Run with compose:   docker-compose up -d"
    echo "  3. Export for air-gap: ./scripts/docker/export-airgap.sh"
    echo ""
}

# Run main function
main "$@"
