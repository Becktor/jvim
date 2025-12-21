# syntax=docker/dockerfile:1.4
# Dev image - extends base with host-specific config (tmux, entrypoint)
ARG JVIM_BASE=ghcr.io/becktor/jvim:latest
ARG BASE_IMAGE=ubuntu:24.04

# =============================================================================
# Stage 1: Build tmux from source (to match host version)
# =============================================================================
FROM ${BASE_IMAGE} AS tmux-builder

ARG TMUX_VERSION

RUN if [ -n "$TMUX_VERSION" ]; then \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential git libevent-dev libncurses-dev bison autoconf automake pkg-config ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch ${TMUX_VERSION} https://github.com/tmux/tmux.git /build/tmux \
    && cd /build/tmux && sh autogen.sh && ./configure --prefix=/usr/local && make && make DESTDIR=/opt/tmux install; \
    else mkdir -p /opt/tmux/usr/local/bin && touch /opt/tmux/usr/local/bin/tmux; fi

# =============================================================================
# Stage 2: Dev image
# =============================================================================
FROM ${JVIM_BASE} AS dev

USER root

# Install tmux runtime deps and gosu for entrypoint
RUN apt-get update && apt-get install -y --no-install-recommends \
    libevent-2.1-7t64 libevent-core-2.1-7t64 libncurses6 gosu \
    && rm -rf /var/lib/apt/lists/*

# Copy tmux from builder (version matched to host)
COPY --from=tmux-builder /opt/tmux/usr/local/bin/tmux /usr/local/bin/tmux

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nvim"]
