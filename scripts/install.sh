#!/usr/bin/env bash
# Build image and install jvim command
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

# Build image
"$SCRIPT_DIR/build.sh"

# Install jvim
mkdir -p "$BIN_DIR"
ln -sf "$REPO_ROOT/bin/jvim" "$BIN_DIR/jvim"

echo ""
echo "Installed: $BIN_DIR/jvim"
echo "Make sure $BIN_DIR is in your PATH"
