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

# Install kubectl
if ! command -v kubectl &> /dev/null; then
  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS_LOWER}/${ARCH_SUFFIX}/kubectl"
  chmod +x kubectl
  if [[ "$OS" == "Linux" ]]; then
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  else
    sudo mv kubectl /usr/local/bin/kubectl
  fi
  rm -f kubectl
else
  echo "kubectl already installed."
fi

# Install k9s
if ! command -v k9s &> /dev/null; then
  echo "Installing k9s..."
  curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/latest/download/k9s_${OS_TITLE}_${ARCH_SUFFIX}.tar.gz"
  tar -xzf k9s.tar.gz k9s
  if [[ "$OS" == "Linux" ]]; then
    sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s
  else
    sudo mv k9s /usr/local/bin/k9s
  fi
  rm k9s.tar.gz
  rm -f LICENSE README.md
else
  echo "k9s already installed."
fi

# Install kind
if ! command -v kind &> /dev/null; then
  echo "Installing kind..."
  curl -Lo ./kind "https://kind.sigs.k8s.io/dl/latest/kind-${OS_LOWER}-${ARCH_SUFFIX}"
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
else
  echo "kind already installed."
fi

# Install helm
if ! command -v helm &> /dev/null; then
  echo "Installing helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "helm already installed."
fi

# Install kubeval
if ! command -v kubeval &> /dev/null; then
  echo "Installing kubeval..."
  curl -Lo kubeval.tar.gz "https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-${OS_LOWER}-${ARCH_SUFFIX}.tar.gz"
  tar -xzf kubeval.tar.gz kubeval
  if [[ "$OS" == "Linux" ]]; then
    sudo install -o root -g root -m 0755 kubeval /usr/local/bin/kubeval
  else
    sudo mv kubeval /usr/local/bin/kubeval
  fi
  rm kubeval.tar.gz
  rm -f LICENSE README.md
else
  echo "kubeval already installed."
fi

# Install yamllint
if ! command -v yamllint &> /dev/null; then
  echo "Installing yamllint..."
  if [[ "$OS" == "Linux" ]]; then
    sudo apt install -y yamllint
  elif [[ "$OS" == "Darwin" ]]; then
    # yamllint should already be installed via brew in the base packages
    echo "yamllint should be installed via brew packages."
  fi
else
  echo "yamllint already installed."
fi

echo "[✔] Kubernetes tools and Helm utilities installed."
