#!/usr/bin/env bash
# Uninstall jvim
set -euo pipefail

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "Uninstalling jvim..."

# Remove symlink
if [[ -L "$BIN_DIR/jvim" ]]; then
    rm "$BIN_DIR/jvim"
    echo "Removed $BIN_DIR/jvim"
fi

# Remove docker images (jvim:UID format)
for img in $(docker images --format '{{.Repository}}:{{.Tag}}' | grep '^jvim:' 2>/dev/null || true); do
    docker rmi "$img" 2>/dev/null && echo "Removed image: $img"
done

# Remove docker volume
if docker volume inspect jvim-data &>/dev/null; then
    docker volume rm jvim-data
    echo "Removed volume: jvim-data"
fi

echo ""
echo "jvim uninstalled."
