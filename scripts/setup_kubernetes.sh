#!/bin/bash

# setup_kubernetes.sh - Installs kubectl, k9s, kind, helm, and related tools for Kubernetes development

set -e

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
  OS_TITLE="Linux"
elif [[ "$OS" == "Darwin" ]]; then
  OS_LOWER="darwin"
  OS_TITLE="Darwin"
else
  echo "[!] Unsupported operating system: $OS"
  exit 1
fi

echo "[+] Installing Kubernetes tools..."

# Install/update kubectl (always fetches latest stable, overwriting any existing binary)
echo "Installing/updating kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS_LOWER}/${ARCH_SUFFIX}/kubectl"
chmod +x kubectl
if [[ "$OS" == "Linux" ]]; then
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
else
  sudo mv kubectl /usr/local/bin/kubectl
fi
rm -f kubectl

# Install/update k9s (always fetches latest release, overwriting any existing binary)
echo "Installing/updating k9s..."
curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/latest/download/k9s_${OS_TITLE}_${ARCH_SUFFIX}.tar.gz"
tar -xzf k9s.tar.gz k9s
if [[ "$OS" == "Linux" ]]; then
  sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s
else
  sudo mv k9s /usr/local/bin/k9s
fi
rm -f k9s k9s.tar.gz LICENSE README.md

# Install/update kind (always fetches the latest tagged release, overwriting any
# existing binary). Note: kind.sigs.k8s.io/dl/latest/ resolves to a nightly/canary
# build from the staging bucket, not the latest stable release, so we resolve the
# tag via the GitHub API instead.
echo "Installing/updating kind..."
KIND_TAG="$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')"
curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_TAG}/kind-${OS_LOWER}-${ARCH_SUFFIX}"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install/update helm (upstream script detects the installed version and only
# replaces it if a newer release is available). get-helm-3 is hardcoded to the
# latest v3.x release, so it can never move us to a v4 major; get-helm-4 is the
# equivalent script for the v4 line.
echo "Installing/updating helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

# Install/update kubeval (always fetches latest release, overwriting any existing binary)
echo "Installing/updating kubeval..."
curl -Lo kubeval.tar.gz "https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-${OS_LOWER}-${ARCH_SUFFIX}.tar.gz"
tar -xzf kubeval.tar.gz kubeval
if [[ "$OS" == "Linux" ]]; then
  sudo install -o root -g root -m 0755 kubeval /usr/local/bin/kubeval
else
  sudo mv kubeval /usr/local/bin/kubeval
fi
rm -f kubeval kubeval.tar.gz LICENSE README.md

# Install/update yamllint
if [[ "$OS" == "Linux" ]]; then
  echo "Installing/updating yamllint..."
  sudo apt install -y yamllint
elif [[ "$OS" == "Darwin" ]]; then
  # yamllint is installed/updated via brew in the base packages
  echo "yamllint is managed via brew packages."
fi

echo "[✔] Kubernetes tools and Helm utilities installed."
