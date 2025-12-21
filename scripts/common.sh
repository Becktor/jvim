#!/usr/bin/env bash
# Shared functions for jvim scripts

check_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Docker not found. Installing..."
        install_docker
    fi

    if ! docker info &>/dev/null; then
        echo "Error: Docker not running or missing permissions."
        echo "  Start: sudo systemctl start docker"
        echo "  Perms: sudo usermod -aG docker $USER && newgrp docker"
        exit 1
    fi
}

install_docker() {
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
    echo "Docker installed. Log out and back in, then re-run the installer."
    exit 0
}
