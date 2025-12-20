#!/usr/bin/env bash
# Quick launcher for jobe-nvim
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Export host UID/GID and username for container user
export USER_UID=$(id -u)
export USER_GID=$(id -g)
export USERNAME="${USERNAME:-nvim}"

# Build if image doesn't exist for this UID
if ! docker image inspect "jobe-nvim:${USER_UID}" &>/dev/null; then
    echo "Building jobe-nvim image for UID ${USER_UID}..."
    docker compose -f "$REPO_ROOT/docker/compose.yml" build
fi

# Run nvim with any passed arguments
exec docker compose -f "$REPO_ROOT/docker/compose.yml" run --rm nvim nvim "$@"
