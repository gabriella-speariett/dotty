#!/usr/bin/env bash
set -euo pipefail

REPO="github.com/gabriella-speariett/dotty"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
LOCAL_BIN="$HOME/.local/bin"
OS_TYPE="$(uname -s)"

echo $SCRIPT_DIR

mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:/opt/homebrew/bin:/usr/local/bin:$PATH"


# Install curl if not already installed
if ! command -v curl &>/dev/null; then
    echo "==> Installing curl..."
    case "$OS_TYPE" in
        Darwin)
            if ! command -v brew &>/dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
            fi
            brew install curl
            ;;
        Linux)
            sudo apt update -qq
            sudo apt install -y -qq curl
            ;;
    esac
fi

echo "==> Bootstrapping dev environment"

# ── Installing fonts ───────────────────────────────────────────────────────

for font_dir in "$SCRIPT_DIR"/fonts/*/; do
    [ -d "$font_dir" ] || continue

    echo "==> Installing fonts from $font_dir..."

    if [[ "$OS_TYPE" == "Darwin" ]]; then
        target=~/Library/Fonts
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        target=~/.local/share/fonts
        mkdir -p "$target"
    fi

    find "$font_dir" -type f -name "*.ttf" -o -name "*.otf" -exec cp -t "$target" {} +

done

# Refresh font cache on Linux
[[ "$OS_TYPE" == "Linux" ]] && fc-cache -fv >> /dev/null


# ── chezmoi ───────────────────────────────────────────────────────────────────
if ! command -v chezmoi &>/dev/null; then
    echo "==> Installing chezmoi..."
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$LOCAL_BIN"
fi

echo "==> Applying dotfiles..."
chezmoi init --apply "$REPO"

# ── just ──────────────────────────────────────────────────────────────────────
if ! command -v just &>/dev/null; then
    echo "==> Installing just..."
    case "$OS_TYPE" in
        Darwin)
            if ! command -v brew &>/dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
            fi
            brew install just
            ;;
        Linux)
            curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
                | bash -s -- --to "$LOCAL_BIN"
            ;;
    esac
fi

# ── install tools ─────────────────────────────────────────────────────────────
echo "==> Installing tools..."
just --justfile "$SCRIPT_DIR/justfile" install

echo ""
echo "==> Done! Restart your shell to apply all changes."
