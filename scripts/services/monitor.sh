#!/bin/bash
#================================================================
# AirGapAICoder - Service Monitoring Script (Unix)
# Monitors Ollama service health and restarts if needed
#
# Author: Fuzemobi, LLC - Chad Rosenbohm
# Usage: ./monitor.sh [check_interval_seconds]
#================================================================

set -eo pipefail

# Configuration
CHECK_INTERVAL="${1:-60}"  # Check every 60 seconds by default
MAX_FAILURES=3              # Restart after 3 consecutive failures
FAILURE_COUNT=0
LOG_FILE="/var/log/airgap-monitor.log"

# Try user log if system log not writable
if [ ! -w "/var/log" ]; then
    LOG_FILE="$HOME/Library/Logs/airgap-monitor.log"
fi

# Ollama API endpoint
OLLAMA_HOST="${OLLAMA_HOST:-localhost:11434}"

#================================================================
# Functions
#================================================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_ollama_process() {
    if pgrep -x "ollama" > /dev/null; then
        return 0
    else
        return 1
    fi
}

check_ollama_api() {
    if curl -s -f "http://$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

restart_ollama() {
    log "Attempting to restart Ollama..."

    # Kill existing process
    pkill -9 ollama 2>/dev/null || true
    sleep 2

    # Restart based on platform
    case "$(uname)" in
        Darwin)
            # macOS: Use launchctl if LaunchAgent exists
            local plist="$HOME/Library/LaunchAgents/com.airgap.ollama.plist"
            if [ -f "$plist" ]; then
                launchctl unload "$plist" 2>/dev/null || true
                launchctl load "$plist"
                log "Restarted via LaunchAgent"
            else
                # Start directly
                nohup ollama serve > /dev/null 2>&1 &
                log "Started ollama serve directly"
            fi
            ;;
        Linux)
            # Linux: Use systemd if available
            if command -v systemctl >/dev/null 2>&1; then
                systemctl --user restart ollama 2>/dev/null || \
                sudo systemctl restart ollama 2>/dev/null || \
                nohup ollama serve > /dev/null 2>&1 &
                log "Restarted via systemd or direct start"
            else
                nohup ollama serve > /dev/null 2>&1 &
                log "Started ollama serve directly"
            fi
            ;;
    esac

    sleep 5

    # Verify restart
    if check_ollama_process && check_ollama_api; then
        log "Ollama successfully restarted"
        FAILURE_COUNT=0
        return 0
    else
        log "ERROR: Failed to restart Ollama"
        return 1
    fi
}

monitor_loop() {
    log "AirGapAICoder monitoring started (interval: ${CHECK_INTERVAL}s)"

    while true; do
        if check_ollama_process; then
            if check_ollama_api; then
                # Both process and API are healthy
                if [ $FAILURE_COUNT -gt 0 ]; then
                    log "Service recovered (was failing)"
                    FAILURE_COUNT=0
                fi
                # Silent success - only log every 10 checks
                if [ $(($(date +%s) % 600)) -lt $CHECK_INTERVAL ]; then
                    log "Status: OK"
                fi
            else
                # Process running but API not responding
                FAILURE_COUNT=$((FAILURE_COUNT + 1))
                log "WARNING: API not responding (failure $FAILURE_COUNT/$MAX_FAILURES)"

                if [ $FAILURE_COUNT -ge $MAX_FAILURES ]; then
                    log "ERROR: Max failures reached - restarting"
                    restart_ollama
                fi
            fi
        else
            # Process not running
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
            log "WARNING: Ollama process not running (failure $FAILURE_COUNT/$MAX_FAILURES)"

            if [ $FAILURE_COUNT -ge $MAX_FAILURES ]; then
                log "ERROR: Max failures reached - restarting"
                restart_ollama
            fi
        fi

        sleep "$CHECK_INTERVAL"
    done
}

#================================================================
# Main
#================================================================

main() {
    echo "================================================================"
    echo "  AirGapAICoder Service Monitor"
    echo "  Monitoring: $OLLAMA_HOST"
    echo "  Check interval: ${CHECK_INTERVAL}s"
    echo "  Max failures before restart: $MAX_FAILURES"
    echo "  Log file: $LOG_FILE"
    echo "================================================================"
    echo

    # Initial check
    log "Performing initial health check..."

    if check_ollama_process && check_ollama_api; then
        log "Initial check: Ollama is healthy"
    else
        log "WARNING: Ollama not healthy at startup"
        restart_ollama
    fi

    # Start monitoring loop
    monitor_loop
}

main "$@"
