# jvim

Containerized Neovim development environment. Consistent config across any system with Docker.

## Install

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/becktor/jvim/main/setup.sh)"
```

Then use:

```bash
jvim                      # Open nvim in current directory
jvim file.py              # Open file
jvim src/                 # Open directory
jvim -O file1.py file2.py # Multiple files
```

## Uninstall

```bash
~/.jvim/scripts/uninstall.sh
```

## Manual Install

```bash
git clone https://github.com/becktor/jvim.git ~/.jvim
~/.jvim/scripts/build.sh
ln -s ~/.jvim/bin/jvim ~/.local/bin/jvim
```

## Structure

```
jvim/
├── setup.sh              # Curl installer
├── docker/
│   ├── Dockerfile        # Multi-stage build
│   ├── compose.yml       # Docker Compose config
│   └── bake.hcl          # Multi-platform builds
├── scripts/
│   ├── build.sh          # Build image
│   ├── install.sh        # Build + install jvim
│   └── uninstall.sh      # Remove jvim
├── bin/
│   └── jvim              # Main launcher
└── .env.example          # Configuration template
```

## How It Works

- Neovim config is cloned from [dotfiles](https://github.com/Becktor/dotfiles) and baked into the image
- Plugins are pre-installed during build via `lazy.nvim`
- Container user UID/GID matches your host user for seamless file permissions
- Workspace directories are mounted from host
- Plugin data persists in a Docker volume

## Configuration

Copy `.env.example` to `.env` and customize:

```bash
# Override dotfiles repo
DOTFILES_REPO=https://github.com/youruser/dotfiles.git
DOTFILES_BRANCH=main

# Custom workspace
WORKSPACE=~/projects
```

## Multi-Platform Builds

```bash
# Local build
docker buildx bake -f docker/bake.hcl dev

# Build for amd64 + arm64 (push to registry)
docker buildx bake -f docker/bake.hcl ci
```

## Rebuilding

Force rebuild with latest dotfiles:

```bash
./scripts/build.sh
```

## Requirements

- Docker with Compose v2
- Docker Buildx (for multi-platform builds)
