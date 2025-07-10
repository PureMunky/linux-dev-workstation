#!/bin/bash

# setup.sh - Main setup entry point for Linux dev workstation
# Target: Ubuntu + Bash + Kubernetes (.NET project)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Starting Linux dev workstation setup..."

# Update and install core packages
"$SCRIPT_DIR/scripts/install_packages.sh"

# Set up dotfiles
echo "[+] Linking dotfiles..."
for file in "$SCRIPT_DIR/dotfiles"/.*; do
  [[ -f "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]] && ln -sf "$file" "$HOME/"
done

# Configure Git
"$SCRIPT_DIR/scripts/setup_git.sh"

# Install Kubernetes tools
"$SCRIPT_DIR/scripts/setup_kubernetes.sh"

# Install .NET CLI
"$SCRIPT_DIR/scripts/setup_dotnet.sh"

# Install Docker
"$SCRIPT_DIR/scripts/setup_docker.sh"

# Install VS Code
"$SCRIPT_DIR/scripts/setup_vscode.sh"

echo "[✔] Setup complete. Restart your terminal to apply changes."
