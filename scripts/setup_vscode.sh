#!/bin/bash

# setup_vscode.sh - Installs Visual Studio Code and common extensions

set -e

echo "[+] Installing VS Code..."

if ! command -v code &> /dev/null; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
  sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  sudo apt update
  sudo apt install -y code
else
  echo "VS Code already installed."
fi

# Install recommended extensions
EXTENSIONS=(
  ms-dotnettools.csharp
  ms-kubernetes-tools.vscode-kubernetes-tools
  eamodio.gitlens
  ms-azuretools.vscode-docker
  editorconfig.editorconfig
)

for extension in "${EXTENSIONS[@]}"; do
  code --install-extension "$extension" --force
done

echo "[✔] VS Code installed with recommended extensions."
