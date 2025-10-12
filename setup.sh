#!/bin/bash

# setup.sh - Main setup entry point for Linux dev workstation
# Target: Ubuntu + Bash + Kubernetes (.NET project)

set -e

find . -name "*.sh" -exec chmod +x {} \;

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Starting Linux dev workstation setup..."

# Update and install core packages
"$SCRIPT_DIR/scripts/install_apt_packages.sh"

# Install Go packages
"$SCRIPT_DIR/scripts/install_go_packages.sh"

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

# Install ArgoCD CLI
"$SCRIPT_DIR/scripts/install_argocd.sh"

# Install Tilt
"$SCRIPT_DIR/scripts/setup_tilt.sh"

# Install Node.js and npm via nvm
"$SCRIPT_DIR/scripts/setup_node.sh"

# Install global npm packages
"$SCRIPT_DIR/scripts/install_npm_packages.sh"

echo "[✔] Setup complete. Restarting shell to apply changes..."
exec bash
