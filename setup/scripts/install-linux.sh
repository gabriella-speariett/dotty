#!/usr/bin/env bash

ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64")

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/utils/helpers.sh"

# Fetch the download URL for the latest GitHub release matching a pattern
github_latest_url() {
    local repo="$1" pattern="$2"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
        | grep "browser_download_url" \
        | grep "${pattern}" \
        | cut -d '"' -f 4 \
        | head -1
}

# ── Prerequisites ─────────────────────────────────────────────────────────────
log_info "==> Updating package lists..."
sudo apt update -qq

# Install some basic tools that are prerequisites for the rest of the installation. These include:
# - curl: for making HTTP requests to download files and interact with APIs.
# - gpg: for verifying the integrity of downloaded files and adding repository keys.
# - git: for cloning repositories and managing version control.
# - apt-transport-https and ca-certificates: for securely fetching packages over HTTPS.
# - build-essential: for compiling software from source if needed.
# - software-properties-common: for managing software repositories and PPAs.
log_info "==> Installing prerequisite packages..."
sudo apt install -y -qq \
    curl \
    gpg \
    git \
    apt-transport-https \
    ca-certificates \
    build-essential \
    software-properties-common

# Install python and go if not already installed, as some tools depend on them
log_info "==> Installing Python and Go (if not already installed)..."
sudo apt install -y -qq python3 golang-go

# ── WezTerm ───────────────────────────────────────────────────────────────────
if ! is_installed wezterm; then
    log_info "==> Installing WezTerm..."
    curl -fsSL https://apt.fury.io/wezfurlong/gpg.key \
        | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    log_info "==> Adding WezTerm repository..."
    echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wezfurlong/ * *" \
        | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update -qq
    sudo apt install -y -qq wezterm
    log_install_result "WezTerm"
fi

apt_install() {
    local name="$1"

    if ! is_installed "$name"; then
        log_info "==> Installing $name..."
        sudo apt install -y -qq "$name"
        log_install_result "$name"
    fi
}

apt_install_with_repo() {
    local name="$1" repo="$2"

    if is_installed "$name"; then
        log_info "==> $name already installed, skipping..."
        return
    fi

    log_info "==> Adding repo for $name..."
    sudo add-apt-repository -y "$repo"
    # apt update fetches package metadata from all configured repos and rebuilds
    # the local package index used by apt install
    sudo apt update -qq

    log_info "==> Installing $name"
    sudo apt install -y -qq "$name"
    log_install_result "$name"
}

install_tool_with_script() {
    local name=$1
    local url=$2
    local args=$3  # Optional arguments for the script itself

    if ! is_installed "$name"; then
        log_info "==> Installing $name..."
        
        # 1. --proto '=https' --tlsv1.2 : Forces modern security
        # 2. -sSfL : Silent, show errors, fail on 404, follow redirects
        # 3. sh <(...) : Process substitution for safe execution
        sh <(curl --proto '=https' --tlsv1.2 -sSfL "$url") $args
        log_install_result "$name"
    fi
}

for package in direnv zoxide tree ripgrep fd-find fzf bat lsd lazygit fastfetch; do
    apt_install "$package"
done

apt_install_with_repo "fish" "ppa:fish-shell/release-4"
apt_install_with_repo "neovim" "ppa:neovim-ppa/stable"

install_tool_with_script uv https://astral.sh/uv/install.sh
install_tool_with_script atuin https://setup.atuin.sh
install_tool_with_script starship https://starship.rs/install.sh "--yes --bin-dir $LOCAL_BIN"
install_tool_with_script zoxide https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh

echo ""
log_info "==> Linux install complete."
log_info "    Ensure $LOCAL_BIN is in your PATH (add to ~/.config/fish/config.fish: set -gx PATH \$HOME/.local/bin \$PATH)"
log_warn "    Some tools may require a restart to be available in your shell."
log_warn "    Changing default shell to fish."

chsh -s "$(which fish)"
