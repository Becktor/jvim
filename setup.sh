#!/usr/bin/env bash
# jvim installer
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/becktor/jvim/main/setup.sh)"
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/becktor/jvim.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.jvim}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "Installing jvim..."
echo ""

# Check for docker
if ! command -v docker &>/dev/null; then
    echo "Docker not found. Installing..."
    if [[ ! -f /etc/os-release ]]; then
        echo "Could not detect OS. Install Docker manually:"
        echo "  https://docs.docker.com/engine/install/"
        exit 1
    fi

    . /etc/os-release
    case "$ID" in
        arch|manjaro|endeavouros)
            sudo pacman -S --noconfirm docker docker-compose
            ;;
        ubuntu|debian|pop|linuxmint)
            sudo apt-get update
            sudo apt-get install -y docker.io docker-compose-v2
            ;;
        fedora)
            sudo dnf install -y docker docker-compose
            ;;
        *)
            echo "Unsupported distro: $ID"
            echo "Install Docker manually: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac

    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"

    echo ""
    echo "Docker installed. Log out and back in, then re-run:"
    echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/becktor/jvim/main/setup.sh)\""
    exit 0
fi

if ! docker info &>/dev/null; then
    echo "Error: Docker not running or missing permissions."
    echo "  Start: sudo systemctl start docker"
    echo "  Perms: sudo usermod -aG docker $USER && newgrp docker"
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

# Build dev image (pulls base from registry, adds host-specific config)
"$INSTALL_DIR/scripts/build.sh"

# Symlink jvim to bin directory
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/bin/jvim" "$BIN_DIR/jvim"

echo ""
echo "Installed: $BIN_DIR/jvim"
[[ ":$PATH:" != *":$BIN_DIR:"* ]] && echo "Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
