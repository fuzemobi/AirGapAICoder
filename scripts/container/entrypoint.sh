#!/bin/bash
set -e

# Start Ollama server
if [[ "$1" == "serve" ]]; then
    echo "Starting Ollama server on $OLLAMA_HOST..."
    exec ollama serve
fi

# Execute other commands
exec "$@"
