#!/bin/bash

# install_packages.sh - Installs base system packages listed in apt.txt

set -e

echo "[+] Installing base packages using go..."
sudo apt update
xargs -a "$(dirname "$0")/../package_lists/go.txt" go install

echo "[✔] Base go packages installed."
