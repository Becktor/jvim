#!/bin/sh
# jvim installer
# Usage: curl -fsSL https://raw.githubusercontent.com/becktor/jvim/main/setup.sh | sh
set -eu

REPO_URL="${REPO_URL:-https://github.com/becktor/jvim.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.jvim}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "Installing jvim..."

# Check for docker
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Attempting to install..."

    case "$(uname -s)" in
        Linux)
            # Install Docker using official convenience script
            curl -fsSL https://get.docker.com | sh

            # Add current user to docker group (avoids needing sudo for docker commands)
            if [ -n "${SUDO_USER:-}" ]; then
                sudo usermod -aG docker "$SUDO_USER"
            elif [ "$(id -u)" -ne 0 ]; then
                sudo usermod -aG docker "$(whoami)"
            fi

            echo "Docker installed. You may need to log out and back in for group changes to take effect."
            ;;
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                echo "Installing Docker via Homebrew..."
                brew install --cask docker
                echo "Please open Docker Desktop to complete setup, then re-run this script."
                exit 1
            else
                echo "Error: Please install Docker Desktop from https://docker.com/products/docker-desktop"
                exit 1
            fi
            ;;
        *)
            echo "Error: Unsupported OS. Please install Docker manually."
            exit 1
            ;;
    esac

    # Verify docker is now available
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker installation failed."
        exit 1
    fi
fi

# Clone or update repo
if [ -d "$INSTALL_DIR" ]; then
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
