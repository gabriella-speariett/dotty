#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/utils/helpers.sh"

FISH_LOCATION="$(command -v fish)"
CURRENT_SHELL="$(dscl . -read /Users/$USER UserShell | awk '{print $2}')"

if [[ "$CURRENT_SHELL" != "$FISH_LOCATION" ]]; then
    if ! grep -qx "$FISH_LOCATION" /etc/shells; then
        log_info "Fish shell not in the allowed shells, adding it..."
        echo "$FISH_LOCATION "| sudo tee -a /etc/shells
    fi
    if chsh -s "$FISH_LOCATION"; then
        log_info "Fish shell is now the default user shell!"
    else
        log_warn "Unable to make fish shell the default user shell..."
    fi
fi
