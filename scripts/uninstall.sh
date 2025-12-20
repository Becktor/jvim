#!/usr/bin/env bash
# jvim uninstaller
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.jvim}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "Uninstalling jvim..."

# Remove symlink
if [[ -L "$BIN_DIR/jvim" ]]; then
    rm "$BIN_DIR/jvim"
    echo "Removed $BIN_DIR/jvim"
fi

# Remove install directory
if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed $INSTALL_DIR"
fi

# Remove docker image
if docker image inspect jvim &>/dev/null; then
    docker rmi jvim
    echo "Removed docker image"
fi

# Remove docker volume
if docker volume inspect jvim-data &>/dev/null; then
    docker volume rm jvim-data
    echo "Removed docker volume"
fi

echo ""
echo "jvim has been uninstalled."
