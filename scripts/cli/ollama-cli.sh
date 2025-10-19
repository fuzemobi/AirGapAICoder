#!/bin/bash
#================================================================
# AirGapAICoder - Remote CLI Wrapper
# Simple HTTP API wrapper for remote Ollama management
#
# Author: Fuzemobi, LLC - Chad Rosenbohm
# Usage: ./ollama-cli.sh <command> [server] [args...]
#================================================================

set -eo pipefail

# Default server
DEFAULT_SERVER="localhost:11434"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

#================================================================
# Helper Functions
#================================================================

usage() {
    cat << EOF
AirGapAICoder Remote CLI

Usage: $0 <command> [server] [args...]

Commands:
  status [server]              Check server health
  models [server]              List available models
  ps [server]                  Show running models
  run <server> <model> <prompt>  Test inference
  pull <server> <model>        Pull a model (requires internet)
  create <server> <name> <modelfile>  Create custom model
  rm <server> <model>          Remove a model
  help                         Show this help

Server:
  Format: hostname:port or IP:port
  Default: $DEFAULT_SERVER
  Examples: 192.168.1.100:11434, airgap-server:11434

Examples:
  $0 status
  $0 status 192.168.1.100:11434
  $0 models 192.168.1.100:11434
  $0 run localhost:11434 qwen:0.5b "Write hello world in Python"

EOF
    exit 0
}

error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_curl() {
    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required but not installed"
    fi
}

check_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        warning "jq not installed - output will be raw JSON"
        warning "Install jq for better formatting: brew install jq"
        return 1
    fi
    return 0
}

api_call() {
    local server="$1"
    local endpoint="$2"
    local method="${3:-GET}"
    local data="$4"

    local url="http://$server/api/$endpoint"

    if [ "$method" = "GET" ]; then
        curl -s -f "$url" || {
            error "Failed to connect to $server"
        }
    else
        curl -s -f -X "$method" "$url" -d "$data" -H "Content-Type: application/json" || {
            error "Failed to execute $method request to $server"
        }
    fi
}

#================================================================
# Commands
#================================================================

cmd_status() {
    local server="${1:-$DEFAULT_SERVER}"

    info "Checking server: $server"

    if api_call "$server" "tags" "GET" >/dev/null 2>&1; then
        success "Server is online and responding"

        # Try to get version
        local response=$(api_call "$server" "tags" "GET" 2>/dev/null)

        if check_jq; then
            local model_count=$(echo "$response" | jq -r '.models | length' 2>/dev/null || echo "?")
            info "Models available: $model_count"
        fi

        return 0
    else
        error "Server is not responding at $server"
    fi
}

cmd_models() {
    local server="${1:-$DEFAULT_SERVER}"

    info "Listing models on: $server"

    local response=$(api_call "$server" "tags" "GET")

    if check_jq; then
        echo "$response" | jq -r '.models[] | "\(.name)\t\(.size / 1000000000 | floor)GB\t\(.modified_at)"' | column -t -s $'\t'
    else
        echo "$response"
    fi
}

cmd_ps() {
    local server="${1:-$DEFAULT_SERVER}"

    info "Checking running models on: $server"

    local response=$(api_call "$server" "ps" "GET")

    if check_jq; then
        echo "$response" | jq -r '.models[] | "\(.name)\t\(.size / 1000000000 | floor)GB\t\(.expires_at)"' | column -t -s $'\t'
    else
        echo "$response"
    fi
}

cmd_run() {
    local server="$1"
    local model="$2"
    local prompt="$3"

    if [ -z "$server" ] || [ -z "$model" ] || [ -z "$prompt" ]; then
        error "Usage: $0 run <server> <model> <prompt>"
    fi

    info "Running inference on: $server"
    info "Model: $model"
    info "Prompt: $prompt"
    echo

    local data=$(cat <<EOF
{
    "model": "$model",
    "prompt": "$prompt",
    "stream": false
}
EOF
)

    local response=$(api_call "$server" "generate" "POST" "$data")

    if check_jq; then
        echo "$response" | jq -r '.response'
    else
        echo "$response"
    fi
}

cmd_pull() {
    local server="$1"
    local model="$2"

    if [ -z "$server" ] || [ -z "$model" ]; then
        error "Usage: $0 pull <server> <model>"
    fi

    warning "Pull requires internet connectivity on the server"
    info "Pulling model: $model on $server"
    echo

    local data=$(cat <<EOF
{
    "name": "$model"
}
EOF
)

    # Pull is a streaming endpoint
    curl -X POST "http://$server/api/pull" \
        -d "$data" \
        -H "Content-Type: application/json" || {
        error "Failed to pull model"
    }

    echo
    success "Model pulled successfully"
}

cmd_create() {
    local server="$1"
    local name="$2"
    local modelfile="$3"

    if [ -z "$server" ] || [ -z "$name" ] || [ -z "$modelfile" ]; then
        error "Usage: $0 create <server> <name> <modelfile_path>"
    fi

    if [ ! -f "$modelfile" ]; then
        error "Modelfile not found: $modelfile"
    fi

    info "Creating custom model: $name on $server"

    local modelfile_content=$(cat "$modelfile")
    local data=$(cat <<EOF
{
    "name": "$name",
    "modelfile": $(echo "$modelfile_content" | jq -R -s .)
}
EOF
)

    api_call "$server" "create" "POST" "$data" >/dev/null

    success "Model created: $name"
}

cmd_rm() {
    local server="$1"
    local model="$2"

    if [ -z "$server" ] || [ -z "$model" ]; then
        error "Usage: $0 rm <server> <model>"
    fi

    warning "This will permanently delete model: $model"
    read -p "Are you sure? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        info "Cancelled"
        exit 0
    fi

    local data=$(cat <<EOF
{
    "name": "$model"
}
EOF
)

    api_call "$server" "delete" "DELETE" "$data" >/dev/null

    success "Model deleted: $model"
}

#================================================================
# Main
#================================================================

main() {
    check_curl

    if [ $# -eq 0 ]; then
        usage
    fi

    local command="$1"
    shift

    case "$command" in
        status)
            cmd_status "$@"
            ;;
        models)
            cmd_models "$@"
            ;;
        ps)
            cmd_ps "$@"
            ;;
        run)
            cmd_run "$@"
            ;;
        pull)
            cmd_pull "$@"
            ;;
        create)
            cmd_create "$@"
            ;;
        rm)
            cmd_rm "$@"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            error "Unknown command: $command. Run '$0 help' for usage."
            ;;
    esac
}

main "$@"
