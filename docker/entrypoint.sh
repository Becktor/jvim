#!/usr/bin/env bash
# Entrypoint that updates user UID/GID to match host at runtime
set -e

TARGET_UID="${HOST_UID:-}"
TARGET_GID="${HOST_GID:-}"
USERNAME="nvim"

# If no target UID specified, just run as nvim user
if [[ -z "$TARGET_UID" ]]; then
    exec gosu "$USERNAME" "$@"
fi

CURRENT_UID=$(id -u "$USERNAME")
CURRENT_GID=$(id -g "$USERNAME")

# Update GID if different
if [[ -n "$TARGET_GID" && "$TARGET_GID" != "$CURRENT_GID" ]]; then
    groupmod -g "$TARGET_GID" "$USERNAME" 2>/dev/null || \
        echo "Warning: Could not change GID to $TARGET_GID" >&2
fi

# Update UID if different
if [[ -n "$TARGET_UID" && "$TARGET_UID" != "$CURRENT_UID" ]]; then
    usermod -u "$TARGET_UID" "$USERNAME" 2>/dev/null || \
        echo "Warning: Could not change UID to $TARGET_UID" >&2
    chown -R "$TARGET_UID:${TARGET_GID:-$CURRENT_GID}" "/home/$USERNAME" 2>/dev/null || true
fi

exec gosu "$USERNAME" "$@"
