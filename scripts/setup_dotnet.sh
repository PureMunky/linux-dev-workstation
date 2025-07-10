#!/bin/bash

# setup_dotnet.sh - Installs .NET SDK from Microsoft package repository

set -e

echo "[+] Installing .NET SDK..."

if ! command -v dotnet &> /dev/null; then
  wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt update
  sudo apt install -y apt-transport-https
  sudo apt update
  sudo apt install -y dotnet-sdk-8.0
else
  echo ".NET SDK already installed."
fi

echo "[✔] .NET SDK installed."
