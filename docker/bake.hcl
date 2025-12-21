variable "REGISTRY" {
  default = "ghcr.io/becktor"
}

variable "IMAGE_NAME" {
  default = "jvim"
}

variable "TAG" {
  default = "latest"
}

variable "NVIM_VERSION" {
  default = "v0.11.0"
}

variable "DOTFILES_REPO" {
  default = "https://github.com/Becktor/dotfiles.git"
}

variable "DOTFILES_BRANCH" {
  default = "main"
}

variable "TMUX_VERSION" {
  default = ""
}

group "default" {
  targets = ["base"]
}

# Base image - generic, built by CI and pushed to registry
target "base" {
  context    = "."
  dockerfile = "docker/Dockerfile.base"
  target     = "base"

  args = {
    NVIM_VERSION    = NVIM_VERSION
    DOTFILES_REPO   = DOTFILES_REPO
    DOTFILES_BRANCH = DOTFILES_BRANCH
  }

  tags = [
    "${REGISTRY}/${IMAGE_NAME}:${TAG}",
    "${REGISTRY}/${IMAGE_NAME}:${NVIM_VERSION}",
  ]

  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]

  cache-from = ["type=gha"]
  cache-to   = ["type=gha,mode=max"]
}

# CI target - multi-platform base image with push
target "ci" {
  inherits = ["base"]
  output   = ["type=registry"]
}

# Dev target - local build with host-specific config
target "dev" {
  context    = "."
  dockerfile = "docker/Dockerfile"
  target     = "dev"

  args = {
    JVIM_BASE    = "${REGISTRY}/${IMAGE_NAME}:${TAG}"
    TMUX_VERSION = TMUX_VERSION
  }

  tags = ["jvim:dev"]

  platforms = []  # Use local platform

  cache-from = ["type=local,src=.cache/buildx"]
  cache-to   = ["type=local,dest=.cache/buildx,mode=max"]

  output = ["type=docker"]
}
