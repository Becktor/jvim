#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# jobe-nvim Setup Script
# Cross-platform Docker installation checker and setup
# Supports: Linux (Ubuntu, Arch, x86_64, arm64), macOS, Windows (WSL/Git Bash)
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# System Detection
# =============================================================================

detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)   echo "amd64" ;;
        aarch64|arm64)  echo "arm64" ;;
        armv7l)         echo "armv7" ;;
        *)              echo "unknown" ;;
    esac
}

detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID:-unknown}"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# =============================================================================
# Docker Checks
# =============================================================================

check_docker_installed() {
    if command -v docker &> /dev/null; then
        return 0
    fi
    return 1
}

check_docker_running() {
    if docker info &> /dev/null; then
        return 0
    fi
    return 1
}

check_docker_compose() {
    # Check for docker compose (v2) or docker-compose (v1)
    if docker compose version &> /dev/null; then
        echo "v2"
        return 0
    elif command -v docker-compose &> /dev/null; then
        echo "v1"
        return 0
    fi
    return 1
}

check_docker_buildx() {
    if docker buildx version &> /dev/null; then
        return 0
    fi
    return 1
}

get_docker_version() {
    docker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

# =============================================================================
# Installation Instructions
# =============================================================================

install_instructions_ubuntu() {
    cat << 'EOF'

Ubuntu/Debian Docker Installation:
──────────────────────────────────
# Remove old versions
sudo apt-get remove docker docker-engine docker.io containerd runc 2>/dev/null || true

# Install prerequisites
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (logout required)
sudo usermod -aG docker $USER

EOF
}

install_instructions_arch() {
    cat << 'EOF'

Arch Linux Docker Installation:
───────────────────────────────
# Install Docker
sudo pacman -S docker docker-compose docker-buildx

# Enable and start Docker service
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Add user to docker group (logout required)
sudo usermod -aG docker $USER

EOF
}

install_instructions_macos() {
    cat << 'EOF'

macOS Docker Installation:
──────────────────────────
Option 1 - Docker Desktop (recommended):
  Download from: https://www.docker.com/products/docker-desktop/

Option 2 - Homebrew:
  brew install --cask docker

Option 3 - Colima (lightweight alternative):
  brew install docker docker-compose colima
  colima start

EOF
}

install_instructions_windows() {
    cat << 'EOF'

Windows Docker Installation:
────────────────────────────
Option 1 - Docker Desktop (recommended):
  Download from: https://www.docker.com/products/docker-desktop/
  Requires WSL2 or Hyper-V

Option 2 - WSL2 with Docker:
  1. Install WSL2: wsl --install
  2. Install Ubuntu from Microsoft Store
  3. Inside WSL, follow Linux installation instructions

EOF
}

show_install_instructions() {
    local os="$1"
    local distro="${2:-}"

    case "$os" in
        linux)
            case "$distro" in
                ubuntu|debian|pop|linuxmint)
                    install_instructions_ubuntu
                    ;;
                arch|manjaro|endeavouros)
                    install_instructions_arch
                    ;;
                *)
                    log_warn "Unknown distro: $distro"
                    log_info "Please install Docker manually: https://docs.docker.com/engine/install/"
                    ;;
            esac
            ;;
        macos)
            install_instructions_macos
            ;;
        windows)
            install_instructions_windows
            ;;
        *)
            log_error "Unsupported OS: $os"
            log_info "Please install Docker manually: https://docs.docker.com/engine/install/"
            ;;
    esac
}

# =============================================================================
# Main Setup
# =============================================================================

main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              jobe-nvim Docker Setup                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Detect system
    local os=$(detect_os)
    local arch=$(detect_arch)
    local distro=""

    if [ "$os" = "linux" ]; then
        distro=$(detect_linux_distro)
    fi

    log_info "Detected OS: $os"
    log_info "Detected Architecture: $arch"
    [ -n "$distro" ] && log_info "Detected Distribution: $distro"
    echo ""

    # Check architecture support
    if [ "$arch" != "amd64" ] && [ "$arch" != "arm64" ]; then
        log_warn "Architecture '$arch' may not be fully supported"
    fi

    # Check Docker installation
    echo "Checking Docker installation..."
    echo "─────────────────────────────────"

    if ! check_docker_installed; then
        log_error "Docker is not installed"
        show_install_instructions "$os" "$distro"
        exit 1
    fi
    log_success "Docker installed ($(get_docker_version))"

    # Check Docker daemon
    if ! check_docker_running; then
        log_error "Docker daemon is not running"
        echo ""
        case "$os" in
            linux)
                log_info "Start Docker with: sudo systemctl start docker"
                ;;
            macos)
                log_info "Start Docker Desktop from Applications"
                ;;
            windows)
                log_info "Start Docker Desktop from Start Menu"
                ;;
        esac
        exit 1
    fi
    log_success "Docker daemon is running"

    # Check Docker Compose
    local compose_version
    if compose_version=$(check_docker_compose); then
        log_success "Docker Compose available ($compose_version)"
    else
        log_error "Docker Compose not found"
        log_info "Install with: sudo apt install docker-compose-plugin (Ubuntu)"
        log_info "           or: sudo pacman -S docker-compose (Arch)"
        exit 1
    fi

    # Check Buildx
    if check_docker_buildx; then
        log_success "Docker Buildx available"
    else
        log_warn "Docker Buildx not found (needed for multi-platform builds)"
        log_info "Install with: docker buildx install"
    fi

    echo ""
    echo "─────────────────────────────────"
    log_success "All checks passed!"
    echo ""

    # Show usage instructions
    cat << 'EOF'
Quick Start:
────────────
  # Build the image
  docker compose build

  # Run Neovim
  docker compose run --rm nvim

  # Or with custom workspace
  WORKSPACE=/path/to/projects docker compose run --rm nvim

Multi-platform Build (with bake):
─────────────────────────────────
  # Local development build
  docker buildx bake dev

  # Multi-platform build (requires registry push)
  docker buildx bake ci

EOF
}

main "$@"
