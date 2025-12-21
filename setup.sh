#!/usr/bin/env bash
# jvim installer
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/becktor/jvim/main/setup.sh)"
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/becktor/jvim.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.jvim}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "Installing jvim..."
echo ""

# Clone or update repo
if [[ -d "$INSTALL_DIR" ]]; then
    echo "Updating existing installation..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    echo "Cloning jvim..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# Run install script (handles docker check, build, symlink)
"$INSTALL_DIR/scripts/install.sh"
