#!/bin/bash
# Entrypoint that updates user UID/GID to match host at runtime
set -e

# Get target UID/GID from environment (passed by docker run)
TARGET_UID="${HOST_UID:-}"
TARGET_GID="${HOST_GID:-}"
USERNAME="${USERNAME:-user}"

# If no target UID specified, just run the command
if [[ -z "$TARGET_UID" ]]; then
    exec "$@"
fi

# Get current UID/GID
CURRENT_UID=$(id -u "$USERNAME" 2>/dev/null || echo "")
CURRENT_GID=$(id -g "$USERNAME" 2>/dev/null || echo "")

# Update GID if different
if [[ -n "$TARGET_GID" && "$TARGET_GID" != "$CURRENT_GID" ]]; then
    groupmod -g "$TARGET_GID" "$USERNAME" 2>/dev/null || true
fi

# Update UID if different
if [[ -n "$TARGET_UID" && "$TARGET_UID" != "$CURRENT_UID" ]]; then
    usermod -u "$TARGET_UID" "$USERNAME" 2>/dev/null || true
    # Fix ownership of home directory
    chown -R "$TARGET_UID:${TARGET_GID:-$CURRENT_GID}" "/home/$USERNAME" 2>/dev/null || true
fi

# Run command as the user
exec gosu "$USERNAME" "$@"
