#!/bin/bash
# Test AirGapAICoder container deployment
# Version: 1.2.0
# Author: Fuzemobi, LLC - Chad Rosenbohm

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
IMAGE_NAME="${IMAGE_NAME:-airgap-ollama}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-airgap-ollama-test}"
TEST_PORT="${TEST_PORT:-11435}"  # Use different port for testing

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

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

test_pass() {
    ((TESTS_PASSED++))
    log_success "✓ $1"
}

test_fail() {
    ((TESTS_FAILED++))
    log_error "✗ $1"
}

run_test() {
    ((TESTS_RUN++))
    echo -e "${BLUE}[TEST $TESTS_RUN]${NC} $1"
}

detect_container_runtime() {
    if command -v docker &> /dev/null; then
        echo "docker"
    elif command -v podman &> /dev/null; then
        echo "podman"
    else
        log_error "Neither Docker nor Podman found."
        exit 1
    fi
}

cleanup() {
    log_info "Cleaning up test container..."
    $RUNTIME rm -f "$CONTAINER_NAME" 2>/dev/null || true
}

# Test 1: Image exists
test_image_exists() {
    run_test "Checking if image exists"

    if $RUNTIME images "$IMAGE_NAME:$IMAGE_TAG" --format "{{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_NAME:$IMAGE_TAG"; then
        test_pass "Image $IMAGE_NAME:$IMAGE_TAG found"
        return 0
    else
        test_fail "Image $IMAGE_NAME:$IMAGE_TAG not found"
        return 1
    fi
}

# Test 2: Container starts
test_container_starts() {
    run_test "Starting container"

    if $RUNTIME run -d \
        --name "$CONTAINER_NAME" \
        -p "$TEST_PORT:11434" \
        -e OLLAMA_HOST=0.0.0.0:11434 \
        "$IMAGE_NAME:$IMAGE_TAG" > /dev/null 2>&1; then
        test_pass "Container started successfully"
        return 0
    else
        test_fail "Container failed to start"
        return 1
    fi
}

# Test 3: Container is running
test_container_running() {
    run_test "Checking if container is running"

    sleep 5  # Give container time to start

    if $RUNTIME ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        test_pass "Container is running"
        return 0
    else
        test_fail "Container is not running"
        $RUNTIME logs "$CONTAINER_NAME" || true
        return 1
    fi
}

# Test 4: Ollama version check
test_ollama_version() {
    run_test "Checking Ollama version"

    if $RUNTIME exec "$CONTAINER_NAME" ollama --version > /dev/null 2>&1; then
        local version=$($RUNTIME exec "$CONTAINER_NAME" ollama --version 2>&1)
        test_pass "Ollama version: $version"
        return 0
    else
        test_fail "Failed to get Ollama version"
        return 1
    fi
}

# Test 5: AirAI CLI check
test_airai_cli() {
    run_test "Checking AirAI CLI"

    if $RUNTIME exec "$CONTAINER_NAME" airai --version > /dev/null 2>&1; then
        local version=$($RUNTIME exec "$CONTAINER_NAME" airai --version 2>&1)
        test_pass "AirAI CLI version: $version"
        return 0
    else
        test_fail "AirAI CLI not found or failed"
        return 1
    fi
}

# Test 6: Ollama API responds
test_ollama_api() {
    run_test "Testing Ollama API"

    # Wait for API to be ready
    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -sf "http://localhost:$TEST_PORT/api/tags" > /dev/null 2>&1; then
            test_pass "Ollama API is responding"
            return 0
        fi
        ((attempt++))
        sleep 2
    done

    test_fail "Ollama API not responding after ${max_attempts} attempts"
    return 1
}

# Test 7: Health check
test_health_check() {
    run_test "Testing container health check"

    # Wait for health check to pass
    local max_attempts=20
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        local health=$($RUNTIME inspect "$CONTAINER_NAME" --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")

        if [ "$health" = "healthy" ]; then
            test_pass "Container health check passed"
            return 0
        elif [ "$health" = "unhealthy" ]; then
            test_fail "Container health check failed"
            return 1
        fi

        ((attempt++))
        sleep 3
    done

    test_fail "Health check timeout"
    return 1
}

# Test 8: GPU detection (if available)
test_gpu_detection() {
    run_test "Testing GPU detection"

    # This test is optional - GPU might not be available in all test environments
    if $RUNTIME exec "$CONTAINER_NAME" nvidia-smi > /dev/null 2>&1; then
        test_pass "GPU detected and accessible"
        return 0
    else
        log_warning "GPU not detected (this is OK for testing without GPU)"
        return 0
    fi
}

# Test 9: Volume mounts
test_volume_mounts() {
    run_test "Testing volume mounts"

    if $RUNTIME exec "$CONTAINER_NAME" test -d /root/.ollama/models; then
        test_pass "Models directory exists"
    else
        test_fail "Models directory not found"
        return 1
    fi

    if $RUNTIME exec "$CONTAINER_NAME" test -d /var/log/ollama; then
        test_pass "Logs directory exists"
    else
        test_fail "Logs directory not found"
        return 1
    fi

    return 0
}

# Test 10: Environment variables
test_environment_variables() {
    run_test "Testing environment variables"

    local ollama_host=$($RUNTIME exec "$CONTAINER_NAME" printenv OLLAMA_HOST 2>/dev/null || echo "")

    if [ "$ollama_host" = "0.0.0.0:11434" ]; then
        test_pass "Environment variables configured correctly"
        return 0
    else
        test_fail "Environment variables not configured (OLLAMA_HOST=$ollama_host)"
        return 1
    fi
}

# Display test summary
display_summary() {
    echo ""
    echo "======================================================="
    echo "  Test Summary"
    echo "======================================================="
    echo "  Total Tests:  $TESTS_RUN"
    echo -e "  ${GREEN}Passed:${NC}       $TESTS_PASSED"
    echo -e "  ${RED}Failed:${NC}       $TESTS_FAILED"
    echo "======================================================="
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "All tests passed!"
        return 0
    else
        log_error "$TESTS_FAILED test(s) failed"
        return 1
    fi
}

# Main execution
main() {
    echo "======================================================="
    echo "  AirGapAICoder - Container Test Suite"
    echo "======================================================="
    echo ""

    # Detect container runtime
    RUNTIME=$(detect_container_runtime)
    log_info "Using container runtime: $RUNTIME"

    # Cleanup any existing test container
    cleanup

    # Run tests
    test_image_exists || exit 1
    test_container_starts || exit 1
    test_container_running || exit 1
    test_ollama_version
    test_airai_cli
    test_ollama_api
    test_health_check
    test_gpu_detection
    test_volume_mounts
    test_environment_variables

    # Display summary
    display_summary
    EXIT_CODE=$?

    # Cleanup
    log_info "Test complete. Container left running for inspection."
    log_info "View logs: $RUNTIME logs $CONTAINER_NAME"
    log_info "Stop and remove: $RUNTIME rm -f $CONTAINER_NAME"

    exit $EXIT_CODE
}

# Trap to ensure cleanup on script exit
trap cleanup EXIT

# Run main function
main "$@"
