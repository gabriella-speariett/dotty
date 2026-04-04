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
# Install python and go if not already installed, as some tools depend on them
log_info "==> Updating package lists..."
sudo apt update -qq
sudo apt install -y -qq \
    curl gpg apt-transport-https ca-certificates \
    build-essential git software-properties-common
sudo apt install -y -qq python3 golang-go

# ── fish shell ────────────────────────────────────────────────────────────────
log_info "==> Installing fish shell..."
if ! is_installed fish; then
    sudo apt-add-repository ppa:fish-shell/release-4
    sudo apt install -y -qq fish
fi

# ── apt packages ──────────────────────────────────────────────────────────────
log_info "==> Installing apt packages..."
sudo apt install -y -qq zsh direnv zoxide tree ripgrep

# ── Neovim stable (PPA) ───────────────────────────────────────────────────────
if ! is_installed nvim; then
    log_info "==> Installing Neovim (stable)..."
    sudo add-apt-repository -y ppa:neovim-ppa/stable
    sudo apt install -y -qq neovim
    log_install_result "Neovim"
fi

# ── glab (GitLab CLI) ─────────────────────────────────────────────────────────
if ! is_installed glab; then
    log_info "==> Installing glab..."
    curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-cli/script.deb.sh \
        | sudo bash
    sudo apt install -y -qq glab
    log_install_result "glab"
fi

# ── WezTerm ───────────────────────────────────────────────────────────────────
if ! is_installed wezterm; then
    log_info "==> Installing WezTerm..."
    curl -fsSL https://apt.fury.io/wezfurlong/gpg.key \
        | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    log_info "==> Adding WezTerm repository..."
    echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wezfurlong/ * *" \
        | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt install -y -qq wezterm
    log_install_result "WezTerm"
fi

# ── uv (Python package manager) ───────────────────────────────────────────────
if ! is_installed uv; then
    log_info "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log_install_result "uv"
fi

# ── Atuin ─────────────────────────────────────────────────────────────────────
if ! is_installed atuin; then
    log_info "==> Installing atuin..."
    bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
    log_install_result "atuin"

fi

# ── Starship ──────────────────────────────────────────────────────────────────
if ! is_installed starship; then
    log_info "==> Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$LOCAL_BIN"
    log_install_result "starship"

fi

# ── lazygit ───────────────────────────────────────────────────────────────────
if ! is_installed lazygit; then
    log_info "==> Installing lazygit..."
    sudo apt install -y -qq lazygit
    log_install_result "lazygit"
fi

# ── fastfetch ─────────────────────────────────────────────────────────────────
if ! is_installed fastfetch; then
    log_info "==> Installing fastfetch..."
    sudo apt install -y -qq fastfetch
    log_install_result "fastfetch"
fi

echo ""
log_info "==> Linux install complete."
log_info "    Ensure $LOCAL_BIN is in your PATH (add to ~/.zshrc: export PATH=\"\$HOME/.local/bin:\$PATH\")"
log_warn "    Some tools may require a restart to be available in your shell."
log_warn "    Changing default shell to fish."

chsh -s "$(which fish)"
