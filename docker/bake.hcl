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
  default = "v0.11.5"
}

variable "NVIM_CONFIG_REPO" {
  default = "https://github.com/Becktor/dev-env.git"
}

variable "NVIM_CONFIG_BRANCH" {
  default = "main"
}

variable "USER_UID" {
  default = "1000"
}

variable "USER_GID" {
  default = "1000"
}

group "default" {
  targets = ["nvim"]
}

target "nvim" {
  context    = "."
  dockerfile = "docker/Dockerfile"

  args = {
    NVIM_VERSION       = NVIM_VERSION
    NVIM_CONFIG_REPO   = NVIM_CONFIG_REPO
    NVIM_CONFIG_BRANCH = NVIM_CONFIG_BRANCH
    USER_UID           = USER_UID
    USER_GID           = USER_GID
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

# Development target - single platform, no push
target "dev" {
  inherits = ["nvim"]

  tags = ["jvim:dev"]

  platforms = []  # Use local platform

  cache-from = ["type=local,src=.cache/buildx"]
  cache-to   = ["type=local,dest=.cache/buildx,mode=max"]

  output = ["type=docker"]
}

# CI target - multi-platform with push
target "ci" {
  inherits = ["nvim"]

  cache-from = ["type=gha"]
  cache-to   = ["type=gha,mode=max"]

  output = ["type=registry"]
}
