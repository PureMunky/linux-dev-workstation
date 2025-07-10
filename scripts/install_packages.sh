#!/bin/bash

# install_packages.sh - Installs base system packages listed in apt.txt

set -e

echo "[+] Installing base packages using apt..."
sudo apt update
xargs -a "$(dirname "$0")/../package_lists/apt.txt" sudo apt install -y

echo "[✔] Base packages installed."
