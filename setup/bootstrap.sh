#!/usr/bin/env bash
set -euo pipefail

REPO="github.com/gabriella-speariett/dotty"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
LOCAL_BIN="$HOME/.local/bin"
OS_TYPE="$(uname -s)"

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

    find "$font_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$target" \;

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

# ── XDG Config Home ───────────────────────────────────────────────────────────
# Set XDG_CONFIG_HOME to ~/configuration so all shells find config properly,
# especially important for SSH/headless systems without wezterm
XDG_LINE='export XDG_CONFIG_HOME="$HOME/configuration"'
if ! grep -qxF "$XDG_LINE" "$HOME/.profile" 2>/dev/null; then
    echo "$XDG_LINE" >> "$HOME/.profile"
fi

# Also set in fish config so it's available for non wezterm fish shells.
# An existing file that differs is backed up rather than clobbered.
FISH_BOOTSTRAP="$HOME/.config/fish/config.fish"
FISH_BOOTSTRAP_CONTENT=$(cat << 'EOF'
set -gx XDG_CONFIG_HOME "$HOME/configuration"

for file in $HOME/configuration/fish/**/*.fish
    source $file
end
EOF
)
mkdir -p "$(dirname "$FISH_BOOTSTRAP")"
if [[ -f "$FISH_BOOTSTRAP" ]] && [[ "$(cat "$FISH_BOOTSTRAP")" != "$FISH_BOOTSTRAP_CONTENT" ]]; then
    echo "==> Backing up existing $FISH_BOOTSTRAP to $FISH_BOOTSTRAP.bak"
    mv "$FISH_BOOTSTRAP" "$FISH_BOOTSTRAP.bak"
fi
echo "$FISH_BOOTSTRAP_CONTENT" > "$FISH_BOOTSTRAP"

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
just --justfile "$REPO_ROOT/justfile" install

echo ""
echo "==> Done! Restart your shell to apply all changes."
