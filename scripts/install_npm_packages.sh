#!/bin/bash

# install_packages.sh - Installs base system packages listed in apt.txt

set -e

echo "[+] Installing npm packages..."

xargs -a "$(dirname "$0")/../package_lists/npm.txt" npm install -g

echo "[✔] Base npm packages installed."
