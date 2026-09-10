#!/bin/bash

# setup_dotnet.sh - Installs .NET SDK

set -e

OS="$(uname -s)"

echo "[+] Installing/updating .NET SDK..."

# Always ensure the target SDK package is installed/updated, even if some other
# .NET SDK version is already present (dotnet supports multiple SDKs side by side,
# and `command -v dotnet` succeeding says nothing about which major version it is).
if [[ "$OS" == "Linux" ]]; then
  # Linux: Install via Microsoft package repository
  wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt update
  sudo apt install -y apt-transport-https
  sudo apt install -y dotnet-sdk-10.0
elif [[ "$OS" == "Darwin" ]]; then
  # macOS: Install via Homebrew
  brew install --cask dotnet-sdk || brew upgrade --cask dotnet-sdk
else
  echo "[!] Unsupported operating system: $OS"
  exit 1
fi

echo "[✔] .NET SDK installed."
