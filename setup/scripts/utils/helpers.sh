#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/logging.sh"

LOG_LEVEL="INFO"

DEBUG="${1:-}"
if [[ "$DEBUG" == "-d" || "$DEBUG" == "--debug" ]]; then
    LOG_LEVEL="DEBUG"
fi

init_logger --level $LOG_LEVEL --utc --no-colour

is_installed() {
    log_info "Checking if $1 is installed..."
    if command -v "$1" &>/dev/null; then
        log_info "$1 is installed."
        return 0
    else
        log_info "$1 is missing, attempting to install..."
        return 1
    fi
}

log_install_result() {
    if [ $? -eq 0 ]; then
        log_info "$1 installed successfully."
    else
        log_error "Failed to install $1. Please do this manually."
    fi
}