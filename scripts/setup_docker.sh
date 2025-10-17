#!/bin/bash

# setup_docker.sh - Installs Docker Engine (Linux) or Docker Desktop (macOS)

set -e

OS="$(uname -s)"

echo "[+] Installing Docker..."

if ! command -v docker &> /dev/null; then
  if [[ "$OS" == "Linux" ]]; then
    # Linux: Install Docker Engine via apt
    sudo apt update
    sudo apt install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker "$USER"
    echo "[✔] Docker installed. You may need to log out and back in for group changes to take effect."
  elif [[ "$OS" == "Darwin" ]]; then
    # macOS: Install Docker Desktop via Homebrew
    echo "Installing Docker Desktop via Homebrew..."
    brew install --cask docker
    echo "[✔] Docker Desktop installed. Please launch Docker Desktop from Applications to complete setup."
  else
    echo "[!] Unsupported operating system: $OS"
    exit 1
  fi
else
  echo "Docker already installed."
  echo "[✔] Docker is ready."
fi
