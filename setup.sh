#!/usr/bin/env bash
# jvim installer
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/becktor/jvim/main/setup.sh)"
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/becktor/jvim.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.jvim}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "Installing jvim..."

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
    echo "Cloning jvim..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# Create bin directory if needed
mkdir -p "$BIN_DIR"

# Symlink jvim to bin directory
ln -sf "$INSTALL_DIR/bin/jvim" "$BIN_DIR/jvim"
chmod +x "$INSTALL_DIR/bin/jvim"

# Get docker image (pull pre-built or build locally)
IMAGE_NAME="ghcr.io/becktor/jvim:latest"
LOCAL_TAG="jvim:$(id -u)"

echo "Pulling pre-built image..."
if docker pull "$IMAGE_NAME" 2>/dev/null; then
    echo "Tagging as $LOCAL_TAG..."
    docker tag "$IMAGE_NAME" "$LOCAL_TAG"
else
    echo "Pull failed, building locally..."
    "$INSTALL_DIR/scripts/build.sh"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Make sure $BIN_DIR is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Then run: jvim"
