#!/usr/bin/env bash
# jobe-nvim installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/becktor/jobe-nvim/main/setup.sh)
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/becktor/jobe-nvim.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.jobe-nvim}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "Installing jobe-nvim..."

# Check for docker
if ! command -v docker &>/dev/null; then
    echo "Error: docker is required but not installed."
    exit 1
fi

# Clone or update repo
if [[ -d "$INSTALL_DIR" ]]; then
    echo "Updating existing installation..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    echo "Cloning jobe-nvim..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# Create bin directory if needed
mkdir -p "$BIN_DIR"

# Symlink jvim to bin directory
ln -sf "$INSTALL_DIR/bin/jvim" "$BIN_DIR/jvim"
chmod +x "$INSTALL_DIR/bin/jvim"

# Build docker image
echo "Building docker image..."
"$INSTALL_DIR/scripts/build.sh"

echo ""
echo "Installation complete!"
echo ""
echo "Make sure $BIN_DIR is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Then run: jvim"
