#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# jobe-nvim Install Script
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# =============================================================================
# Pre-flight checks
# =============================================================================

check_docker() {
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed"
        log_info "Run ./scripts/setup.sh for installation instructions"
        exit 1
    fi

    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi

    if ! docker compose version &>/dev/null; then
        log_error "Docker Compose not found"
        exit 1
    fi

    log_success "Docker is ready"
}

# =============================================================================
# Build image
# =============================================================================

build_image() {
    log_info "Building jobe-nvim image..."

    export USER_UID=$(id -u)
    export USER_GID=$(id -g)
    export USERNAME="${USERNAME:-nvim}"
    export CACHE_BUST=$(date +%s)

    docker compose -f "$REPO_ROOT/docker/compose.yml" build --build-arg CACHE_BUST="${CACHE_BUST}"

    log_success "Image built: jobe-nvim:${USER_UID} (user: ${USERNAME})"
}

# =============================================================================
# Install jvim command
# =============================================================================

install_jvim() {
    local target="$INSTALL_DIR/jvim"

    log_info "Installing jvim to $target"

    if [[ -w "$INSTALL_DIR" ]]; then
        ln -sf "$REPO_ROOT/bin/jvim" "$target"
    else
        log_info "Requires sudo for $INSTALL_DIR"
        sudo ln -sf "$REPO_ROOT/bin/jvim" "$target"
    fi

    log_success "Installed: $target"
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              jobe-nvim Installer                             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Check Docker
    check_docker
    echo ""

    # Build image
    build_image
    echo ""

    # Install jvim
    install_jvim
    echo ""

    # Done
    echo "─────────────────────────────────────────────────────────────────"
    log_success "Installation complete!"
    echo ""
    echo "Usage:"
    echo "  jvim                    # Open nvim in current directory"
    echo "  jvim file.py            # Open file"
    echo "  jvim src/               # Open directory"
    echo "  jvim -O file1 file2     # Multiple files"
    echo ""
}

main "$@"
