#!/bin/bash
# setup_cld.sh - Build Claude CLI sandbox images
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "[+] Building Claude CLI sandbox base image..."
if ! docker image inspect claude-cli-sandbox &>/dev/null; then
  docker build -t claude-cli-sandbox -f "$REPO_DIR/commands/Dockerfile.claude" "$REPO_DIR/commands"
else
  echo "    Base image already exists. Use cld-rebuild to force rebuild."
fi

# Build workspace-specific image if .cld/Dockerfile exists
if [[ -f "$REPO_DIR/.cld/Dockerfile" ]]; then
  PROJECT_NAME=$(basename "$REPO_DIR")
  IMAGE_NAME="claude-sandbox-${PROJECT_NAME}"
  echo "[+] Building workspace image '$IMAGE_NAME'..."
  if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    docker build -t "$IMAGE_NAME" -f "$REPO_DIR/.cld/Dockerfile" "$REPO_DIR/.cld"
  else
    echo "    Workspace image already exists. Use cld-rebuild to force rebuild."
  fi
fi

echo "[+] Claude sandbox images ready."
