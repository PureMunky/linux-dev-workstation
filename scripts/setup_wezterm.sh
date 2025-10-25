#!/bin/bash

# setup_wezterm.sh - Installs WezTerm terminal emulator

set -e

OS="$(uname -s)"

echo "[+] Installing WezTerm..."

if ! command -v wezterm &> /dev/null; then
  if [[ "$OS" == "Linux" ]]; then
    # Linux: Install via apt repository (recommended method)
    echo "Adding WezTerm apt repository..."
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

    echo "Installing WezTerm via apt..."
    sudo apt update
    sudo apt install -y wezterm
  elif [[ "$OS" == "Darwin" ]]; then
    # macOS: Install via Homebrew
    brew install --cask wezterm
  else
    echo "[!] Unsupported operating system: $OS"
    exit 1
  fi
else
  echo "WezTerm already installed."
fi

echo "[✔] WezTerm installed successfully."
