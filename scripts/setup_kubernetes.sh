#!/bin/bash

# setup_kubernetes.sh - Installs kubectl, k9s, kind, helm, and related tools for Kubernetes development

set -e

echo "[+] Installing Kubernetes tools..."

# Install kubectl
if ! command -v kubectl &> /dev/null; then
  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
else
  echo "kubectl already installed."
fi

# Install k9s
if ! command -v k9s &> /dev/null; then
  echo "Installing k9s..."
  curl -Lo k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
  tar -xzf k9s.tar.gz k9s
  sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s
  rm k9s k9s.tar.gz
else
  echo "k9s already installed."
fi

# Install kind
if ! command -v kind &> /dev/null; then
  echo "Installing kind..."
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
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

# Install helm linting and templating tools
if ! command -v kubeval &> /dev/null; then
  echo "Installing kubeval..."
  curl -Lo kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
  tar -xzf kubeval.tar.gz kubeval
  sudo install -o root -g root -m 0755 kubeval /usr/local/bin/kubeval
  rm kubeval kubeval.tar.gz
else
  echo "kubeval already installed."
fi

if ! command -v yamllint &> /dev/null; then
  echo "Installing yamllint..."
  sudo apt install -y yamllint
else
  echo "yamllint already installed."
fi

echo "[✔] Kubernetes tools and Helm utilities installed."
