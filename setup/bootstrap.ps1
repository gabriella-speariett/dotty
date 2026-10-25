#Requires -RunAsAdministrator

$BOOTSTRAP_URL = "https://raw.githubusercontent.com/gabriella-speariett/dotty/main/setup/bootstrap.sh"

Write-Host "==> Bootstrapping dev environment (Windows)"

# ── WSL ───────────────────────────────────────────────────────────────────────
$wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
$ubuntuInstalled = wsl -l -q 2>$null | Select-String "Ubuntu"

if (-not $wslInstalled -or -not $ubuntuInstalled) {
    Write-Host "==> Installing WSL with Ubuntu..."
    wsl --install -d Ubuntu

    Write-Host ""
    Write-Host "WSL requires a restart to complete installation."
    Write-Host "After restarting, open Ubuntu from the Start Menu to finish setup,"
    Write-Host "then run the Linux bootstrap inside it:"
    Write-Host ""
    Write-Host "  bash -c `"`$(curl -fsSL $BOOTSTRAP_URL)`""
    Write-Host ""
    $restart = Read-Host "Restart now? (y/n)"
    if ($restart -eq 'y') { Restart-Computer }
    exit 0
}

# ── Run Linux bootstrap inside WSL ───────────────────────────────────────────
Write-Host "==> Running Linux bootstrap inside Ubuntu (WSL)..."
# Download to a file rather than piping into bash, so the script's prompts
# (chezmoi, sudo, chsh) read from the terminal instead of from the pipe.
wsl -d Ubuntu -- bash -c "curl -fsSL $BOOTSTRAP_URL -o /tmp/bootstrap.sh && bash /tmp/bootstrap.sh"
