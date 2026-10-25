#!/usr/bin/env bash
set -euo pipefail

REPO="github.com/gabriella-speariett/dotty"
# chezmoi's default source directory. Hardcoded rather than derived from
# BASH_SOURCE, because this script may be run from a curl download with no
# file on disk (see README), and the repo isn't cloned until further down.
REPO_ROOT="$HOME/.local/share/chezmoi"
LOCAL_BIN="$HOME/.local/bin"
OS_TYPE="$(uname -s)"

mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "==> Bootstrapping dev environment"

# ── Prerequisites (git, curl) ─────────────────────────────────────────────────
case "$OS_TYPE" in
    Darwin)
        # curl ships with macOS. git does not: /usr/bin/git is a stub until the
        # Xcode Command Line Tools are installed, and the Homebrew installer
        # installs them for us.
        if ! command -v brew &>/dev/null; then
            echo "==> Installing Homebrew (and Xcode Command Line Tools)..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
        fi
        if ! xcode-select --print-path &>/dev/null; then
            echo "Xcode Command Line Tools are missing. Run 'xcode-select --install', then re-run this script." >&2
            exit 1
        fi
        ;;
    Linux)
        # fontconfig provides fc-cache, used after installing fonts below.
        # Server and cloud images don't ship it.
        if ! command -v git &>/dev/null || ! command -v curl &>/dev/null || ! command -v fc-cache &>/dev/null; then
            echo "==> Installing git, curl and fontconfig..."
            sudo apt update -qq
            sudo apt install -y -qq git curl fontconfig
        fi
        ;;
esac

# ── Clone the repo ────────────────────────────────────────────────────────────
if [[ ! -d "$REPO_ROOT/.git" ]]; then
    echo "==> Cloning $REPO into $REPO_ROOT..."
    git clone "https://$REPO.git" "$REPO_ROOT"
fi

# ── Installing fonts ───────────────────────────────────────────────────────

for font_dir in "$REPO_ROOT"/setup/fonts/*/; do
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
# XDG_CONFIG_HOME=~/configuration is scoped to interactive fish shells only.
# It must never reach ~/.profile: the desktop session reads that, and GNOME's
# dconf would then look for settings in ~/configuration/dconf and appear reset.
# Earlier versions of this script appended it there, so remove it if present.
XDG_LINE='export XDG_CONFIG_HOME="$HOME/configuration"'
if grep -qxF "$XDG_LINE" "$HOME/.profile" 2>/dev/null; then
    echo "==> Removing XDG_CONFIG_HOME export from ~/.profile"
    PROFILE_TMP=$(mktemp)
    # grep exits 1 when it outputs nothing, which would trip `set -e`
    grep -vxF "$XDG_LINE" "$HOME/.profile" > "$PROFILE_TMP" || true
    cat "$PROFILE_TMP" > "$HOME/.profile"
    rm "$PROFILE_TMP"
fi

# Set in fish config for interactive shells (including SSH). The guard matters:
# GNOME starts its session via `$SHELL -l -c ...`, a non-interactive fish that
# still reads this file. An existing file that differs is backed up rather than clobbered.
FISH_BOOTSTRAP="$HOME/.config/fish/config.fish"
FISH_BOOTSTRAP_CONTENT=$(cat << 'EOF'
if status is-interactive
    set -gx XDG_CONFIG_HOME "$HOME/configuration"
end

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
