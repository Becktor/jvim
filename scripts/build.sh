#!/usr/bin/env bash
# Build jvim image (universal - UID/GID remapped at runtime)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

export CACHE_BUST=$(date +%s)

echo "Building jvim image..."
echo ""

docker compose -f "$REPO_ROOT/docker/compose.yml" build --build-arg CACHE_BUST="${CACHE_BUST}" "$@"

echo ""
echo "Done! Run with: jvim"
