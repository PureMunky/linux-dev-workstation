#!/bin/bash

set -e
# install_argocd.sh - Install ArgoCD CLI

echo "[+] Installing ArgoCD CLI."

if ! command -v argocd &> /dev/null; then
  echo "ArgoCD CLI not found. Installing..."
  curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
  rm argocd-linux-amd64
else
  echo "ArgoCD CLI already installed."
  exit 0
fi


echo "[✔] ArgoCD CLI installed."