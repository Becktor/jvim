#!/usr/bin/env bash
# Build jvim with host UID/GID
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Export host UID/GID and username for container user
export USER_UID=$(id -u)
export USER_GID=$(id -g)
export USERNAME="${USERNAME:-$(whoami)}"
export CACHE_BUST=$(date +%s)

# Detect host tmux version (for vim-tmux-navigator compatibility)
if command -v tmux &>/dev/null; then
    export TMUX_VERSION=$(tmux -V | sed 's/tmux //')
fi

echo "Building jvim image..."
echo "  UID: ${USER_UID}"
echo "  GID: ${USER_GID}"
echo "  User: ${USERNAME}"
[[ -n "${TMUX_VERSION:-}" ]] && echo "  tmux: ${TMUX_VERSION}"
echo ""

docker compose -f "$REPO_ROOT/docker/compose.yml" build --build-arg CACHE_BUST="${CACHE_BUST}" "$@"

echo ""
echo "Done! Run with: jvim"
