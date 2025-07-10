#!/bin/bash

# setup_git.sh - Configure global git settings

set -e

echo "[+] Configuring Git..."
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor "vim"
git config --global init.defaultBranch main

echo "[✔] Git configured."
