#!/bin/bash

set -e
# install_argocd.sh - Install ArgoCD CLI

OS="$(uname -s)"
ARCH="$(uname -m)"

# Determine binary architecture string
if [[ "$ARCH" == "x86_64" ]]; then
  ARCH_SUFFIX="amd64"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
  ARCH_SUFFIX="arm64"
else
  echo "[!] Unsupported architecture: $ARCH"
  exit 1
fi

# Determine OS-specific strings
if [[ "$OS" == "Linux" ]]; then
  OS_LOWER="linux"
elif [[ "$OS" == "Darwin" ]]; then
  OS_LOWER="darwin"
else
  echo "[!] Unsupported operating system: $OS"
  exit 1
fi

echo "[+] Installing ArgoCD CLI."

if ! command -v argocd &> /dev/null; then
  echo "ArgoCD CLI not found. Installing..."
  curl -sSL -o argocd-binary "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-${OS_LOWER}-${ARCH_SUFFIX}"
  chmod +x argocd-binary
  sudo mv argocd-binary /usr/local/bin/argocd
else
  echo "ArgoCD CLI already installed."
  exit 0
fi

echo "[✔] ArgoCD CLI installed."