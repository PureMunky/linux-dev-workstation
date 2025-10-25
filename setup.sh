#!/bin/bash

# setup.sh - Main setup entry point for cross-platform dev workstation
# Target: Ubuntu/macOS + Bash + Kubernetes (.NET project)

set -e

find . -name "*.sh" -exec chmod +x {} \;

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# Detect operating system
if [[ "$OS" == "Linux" ]]; then
  OS_NAME="Linux (Ubuntu)"
  PKG_MGR="APT"
elif [[ "$OS" == "Darwin" ]]; then
  OS_NAME="macOS"
  PKG_MGR="Homebrew"
else
  echo "Unsupported operating system: $OS"
  exit 1
fi

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Helper functions for visual output
print_separator() {
  echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

print_step_start() {
  echo ""
  print_separator
  echo -e "${YELLOW}${BOLD}▶ STARTING: $1${NC}"
  print_separator
  echo ""
}

print_step_end() {
  echo ""
  echo -e "${GREEN}${BOLD}✔ COMPLETED: $1${NC}"
  print_separator
  echo ""
}

echo ""
print_separator
echo -e "${BOLD}Starting dev workstation setup for ${OS_NAME}...${NC}"
print_separator
echo ""

# Update and install core packages
print_step_start "${PKG_MGR} Packages Installation"
"$SCRIPT_DIR/scripts/install_apt_packages.sh"
print_step_end "${PKG_MGR} Packages Installation"

# Install Go packages
print_step_start "Go Packages Installation"
"$SCRIPT_DIR/scripts/install_go_packages.sh"
print_step_end "Go Packages Installation"

# Set up dotfiles
print_step_start "Dotfiles Setup"
for file in "$SCRIPT_DIR/dotfiles"/.*; do
  [[ -f "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]] && ln -sf "$file" "$HOME/"
done
print_step_end "Dotfiles Setup"

# Configure Git
print_step_start "Git Configuration"
"$SCRIPT_DIR/scripts/setup_git.sh"
print_step_end "Git Configuration"

# Install Kubernetes tools
print_step_start "Kubernetes Tools Installation"
"$SCRIPT_DIR/scripts/setup_kubernetes.sh"
print_step_end "Kubernetes Tools Installation"

# Install .NET CLI
print_step_start ".NET CLI Installation"
"$SCRIPT_DIR/scripts/setup_dotnet.sh"
print_step_end ".NET CLI Installation"

# Install Docker
print_step_start "Docker Installation"
"$SCRIPT_DIR/scripts/setup_docker.sh"
print_step_end "Docker Installation"

# Install VS Code
print_step_start "VS Code Installation"
"$SCRIPT_DIR/scripts/setup_vscode.sh"
print_step_end "VS Code Installation"

# Install WezTerm
print_step_start "WezTerm Installation"
"$SCRIPT_DIR/scripts/setup_wezterm.sh"
print_step_end "WezTerm Installation"

# Install ArgoCD CLI
print_step_start "ArgoCD CLI Installation"
"$SCRIPT_DIR/scripts/install_argocd.sh"
print_step_end "ArgoCD CLI Installation"

# Install Tilt
print_step_start "Tilt Installation"
"$SCRIPT_DIR/scripts/setup_tilt.sh"
print_step_end "Tilt Installation"

# Install Node.js and npm via nvm
print_step_start "Node.js Installation"
"$SCRIPT_DIR/scripts/setup_node.sh"
print_step_end "Node.js Installation"

# Install global npm packages
print_step_start "NPM Packages Installation"
"$SCRIPT_DIR/scripts/install_npm_packages.sh"
print_step_end "NPM Packages Installation"

echo ""
print_separator
echo -e "${GREEN}${BOLD}✔✔✔ SETUP COMPLETE ✔✔✔${NC}"
print_separator
echo -e "${YELLOW}Restarting shell to apply changes...${NC}"
echo ""
exec bash
