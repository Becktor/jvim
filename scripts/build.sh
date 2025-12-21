#!/usr/bin/env bash
# Build jvim dev image
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

export USER_UID=$(id -u)
export USER_GID=$(id -g)
export JVIM_BASE="${JVIM_BASE:-ghcr.io/becktor/jvim:latest}"

# Detect host tmux version for vim-tmux-navigator
if command -v tmux &>/dev/null; then
    export TMUX_VERSION=$(tmux -V | sed 's/tmux //')
fi

echo "Building jvim..."
echo "  Base:  ${JVIM_BASE}"
echo "  Image: jvim:${USER_UID}"
[[ -n "${TMUX_VERSION:-}" ]] && echo "  tmux:  ${TMUX_VERSION}"
echo ""

# Pull base image
docker pull "${JVIM_BASE}" || echo "Warning: Could not pull base, using cache"

# Build dev image
docker compose -f "$REPO_ROOT/docker/compose.yml" build "$@"

echo ""
echo "Done! Run: jvim [file|dir]"
