#!/bin/bash
# jvim entrypoint - remap container user UID/GID to match host at runtime
set -e

TARGET_UID="${HOST_UID:-1000}"
TARGET_GID="${HOST_GID:-1000}"
USERNAME="nvim"

# If running as root, fix UID/GID and drop privileges
if [ "$(id -u)" = "0" ]; then
    CUR_UID=$(id -u "$USERNAME")
    CUR_GID=$(id -g "$USERNAME")

    # Remap GID if needed
    if [ "$CUR_GID" != "$TARGET_GID" ]; then
        groupmod -g "$TARGET_GID" "$USERNAME" 2>/dev/null || true
    fi

    # Remap UID if needed
    if [ "$CUR_UID" != "$TARGET_UID" ]; then
        usermod -u "$TARGET_UID" -g "$TARGET_GID" "$USERNAME" 2>/dev/null || true
    fi

    # Fix ownership of key directories (avoids slow full-home recursive chown)
    chown -R "$USERNAME:$USERNAME" \
        "/home/$USERNAME/.config" \
        "/home/$USERNAME/.local" \
        2>/dev/null || true

    # Ensure workspace and cache dirs are writable
    for dir in "/home/$USERNAME/.cache" "/home/$USERNAME/workspace"; do
        if [ -d "$dir" ]; then
            chown "$USERNAME:$USERNAME" "$dir"
        fi
    done

    exec gosu "$USERNAME" "$@"
fi

# Already running as the correct user (non-root), just exec
exec "$@"
