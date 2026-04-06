#!/usr/bin/env bash
set -euo pipefail

if ! command -v code &>/dev/null; then
    echo "VS Code not found, skipping extensions."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
BREWFILE="$(cd "$SCRIPT_DIR/../.." && pwd)/Brewfile"

if [ ! -f "$BREWFILE" ]; then
    echo "Brewfile not found at $BREWFILE, skipping extensions."
    exit 1
fi

echo "==> Installing VS Code extensions..."
failed=()

while IFS= read -r ext; do
    if ! code --install-extension "$ext" --force 2>/dev/null; then
        failed+=("$ext")
    fi
done < <(grep '^vscode ' "$BREWFILE" | sed 's/^vscode "\(.*\)"/\1/')

if [ ${#failed[@]} -gt 0 ]; then
    echo ""
    echo "The following extensions failed to install:"
    printf '  - %s\n' "${failed[@]}"
fi

echo "==> Extensions done."
