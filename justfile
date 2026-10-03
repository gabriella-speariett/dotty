# Dev environment setup
# Run `just` to see available tasks

set shell := ["bash", "-c"]

setup_dir := justfile_directory() / "setup"

default:
    @just --list

# Install all tools for the current platform
install:
    #!/usr/bin/env bash
    case "$(uname -s)" in
        Darwin) just --justfile {{justfile()}} mac ;;
        Linux)  just --justfile {{justfile()}} linux ;;
        *) echo "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac

# Mac: install via Homebrew
mac:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v brew &>/dev/null; then
        echo "==> Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi
    echo "==> Running brew bundle..."
    brew bundle --file {{setup_dir}}/Brewfile
    bash {{setup_dir}}/scripts/install-mac.sh

# Linux (Ubuntu): install all tools
linux:
    @bash {{setup_dir}}/scripts/install-linux.sh

# Install VS Code extensions (cross-platform)
extensions:
    @bash {{setup_dir}}/scripts/install-extensions.sh

# Re-run install (same as install, useful for updates)
update: install
