#!/bin/bash

# setup_dotnet.sh - Installs .NET SDK

set -e

OS="$(uname -s)"

echo "[+] Installing .NET SDK..."

if ! command -v dotnet &> /dev/null; then
  if [[ "$OS" == "Linux" ]]; then
    # Linux: Install via Microsoft package repository
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y apt-transport-https
    sudo apt update
    sudo apt install -y dotnet-sdk-8.0
  elif [[ "$OS" == "Darwin" ]]; then
    # macOS: Install via Homebrew
    brew install --cask dotnet-sdk
  else
    echo "[!] Unsupported operating system: $OS"
    exit 1
  fi
else
  echo ".NET SDK already installed."
fi

echo "[✔] .NET SDK installed."
