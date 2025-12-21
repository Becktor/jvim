# syntax=docker/dockerfile:1.4
ARG BASE_IMAGE=ubuntu:24.04

# =============================================================================
# Stage 1: Build Neovim from source (for latest stable)
# =============================================================================
FROM ${BASE_IMAGE} AS neovim-builder

ARG NVIM_VERSION=v0.11.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    gettext \
    git \
    ninja-build \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone --depth 1 --branch ${NVIM_VERSION} https://github.com/neovim/neovim.git && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make DESTDIR=/opt/nvim install

# =============================================================================
# Stage 1b: Build tmux from source (to match host version for vim-tmux-navigator)
# Only builds if TMUX_VERSION is provided
# =============================================================================
FROM ${BASE_IMAGE} AS tmux-builder

ARG TMUX_VERSION

RUN if [ -n "$TMUX_VERSION" ]; then \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libevent-dev \
        libncurses-dev \
        bison \
        autoconf \
        automake \
        pkg-config \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch ${TMUX_VERSION} https://github.com/tmux/tmux.git /build/tmux \
    && cd /build/tmux \
    && sh autogen.sh \
    && ./configure --prefix=/usr/local \
    && make \
    && make DESTDIR=/opt/tmux install; \
    else \
        mkdir -p /opt/tmux/usr/local/bin && touch /opt/tmux/usr/local/bin/tmux; \
    fi

# =============================================================================
# Stage 2: Runtime image
# =============================================================================
FROM ${BASE_IMAGE} AS runtime

LABEL maintainer="jobe"
LABEL description="Containerized Neovim development environment"

ARG USERNAME=nvim
ARG USER_UID=1000
ARG USER_GID=1000

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    ripgrep \
    fd-find \
    fzf \
    build-essential \
    nodejs \
    npm \
    python3 \
    python3-venv \
    cargo \
    xclip \
    zsh \
    locales \
    ca-certificates \
    libevent-2.1-7t64 \
    libevent-core-2.1-7t64 \
    libncurses6 \
    gosu \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && ln -s $(which fdfind) /usr/local/bin/fd \
    && npm install -g tree-sitter-cli markdownlint-cli2 \
    && curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Copy Neovim from builder
COPY --from=neovim-builder /opt/nvim/usr/local /usr/local

# Copy tmux from builder (version matched to host for vim-tmux-navigator)
COPY --from=tmux-builder /opt/tmux/usr/local/bin/tmux /usr/local/bin/tmux

# Rename ubuntu user/group and set UID/GID to match host
RUN groupmod -n ${USERNAME} ubuntu && \
    usermod -l ${USERNAME} -d /home/${USERNAME} -m ubuntu && \
    usermod -u ${USER_UID} ${USERNAME} && \
    groupmod -g ${USER_GID} ${USERNAME} && \
    chsh -s /bin/zsh ${USERNAME} && \
    mkdir -p /home/${USERNAME}/.config /home/${USERNAME}/.local/share/nvim && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Setup user and directories
RUN mkdir -p /home/${USERNAME}/workspace \
    /home/${USERNAME}/.local/share/nvim \
    /home/${USERNAME}/.local/bin && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Install Python tools via uv (as user)
USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN uv tool install ty@latest

# Clone nvim config and install plugins (will be overwritten by mount at runtime)
ARG DOTFILES_REPO=https://github.com/Becktor/dotfiles.git
ARG DOTFILES_BRANCH=main
ARG CACHE_BUST=1

RUN git clone --depth 1 --branch ${DOTFILES_BRANCH} ${DOTFILES_REPO} /tmp/dotfiles && \
    cp -r /tmp/dotfiles/nvim /home/${USERNAME}/.config/nvim && \
    rm -rf /tmp/dotfiles

# Install all nvim plugins via lazy.nvim
# Note: Treesitter parsers install on first run and persist in the data volume
RUN nvim --headless "+Lazy! sync" +qa

# Switch back to root for entrypoint (it will switch to user)
USER root

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Store username for entrypoint
ENV USERNAME=${USERNAME}
ENV HOME=/home/${USERNAME}
ENV XDG_CONFIG_HOME=/home/${USERNAME}/.config
ENV XDG_DATA_HOME=/home/${USERNAME}/.local/share
ENV PATH="/home/${USERNAME}/.local/bin:$PATH"
ENV EDITOR=nvim
ENV VISUAL=nvim

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nvim"]
