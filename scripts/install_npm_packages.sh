#!/bin/bash

# install_packages.sh - Installs base system packages listed in apt.txt

set -e

echo "[+] Installing npm packages..."

xargs npm install -g < "$(dirname "$0")/../package_lists/npm.txt"

echo "[✔] Base npm packages installed."
