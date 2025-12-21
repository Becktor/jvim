#!/usr/bin/env bash
# Install jvim
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

# Load shared functions
source "$SCRIPT_DIR/common.sh"

echo "Installing jvim..."
echo ""

check_docker

# Build image
"$SCRIPT_DIR/build.sh"

# Install symlink
mkdir -p "$BIN_DIR"
ln -sf "$REPO_ROOT/bin/jvim" "$BIN_DIR/jvim"

echo ""
echo "Installed: $BIN_DIR/jvim"
[[ ":$PATH:" != *":$BIN_DIR:"* ]] && echo "Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
