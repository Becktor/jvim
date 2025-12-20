#!/usr/bin/env bash
# Build jobe-nvim with host UID/GID
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Export host UID/GID and username for container user
export USER_UID=$(id -u)
export USER_GID=$(id -g)
export USERNAME="${USERNAME:-nvim}"
export CACHE_BUST=$(date +%s)

echo "Building jobe-nvim image..."
echo "  UID: ${USER_UID}"
echo "  GID: ${USER_GID}"
echo "  User: ${USERNAME}"
echo ""

docker compose build --build-arg CACHE_BUST="${CACHE_BUST}" "$@"

echo ""
echo "Done! Run with: ./run.sh"
