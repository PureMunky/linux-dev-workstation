#!/bin/bash

# install_packages.sh - Installs base system packages listed in apt.txt

set -e

echo "[+] Installing base packages using go..."

xargs go install < "$(dirname "$0")/../package_lists/go.txt"

echo "[✔] Base go packages installed."
