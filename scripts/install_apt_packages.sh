#!/bin/bash

# install_packages.sh - Installs base system packages using the appropriate package manager

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

if [[ "$OS" == "Linux" ]]; then
  echo "[+] Installing base packages using apt..."
  sudo apt update
  xargs sudo apt install -y < "$SCRIPT_DIR/../package_lists/apt.txt"
  echo "[✔] Base apt packages installed."
elif [[ "$OS" == "Darwin" ]]; then
  echo "[+] Installing base packages using brew..."

  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

  xargs -n 1 brew install < "$SCRIPT_DIR/../package_lists/brew.txt"
  echo "[✔] Base brew packages installed."
else
  echo "[!] Unsupported operating system: $OS"
  exit 1
fi
