#!/bin/bash

# setup_git.sh - Configure global git settings

set -e

echo "[+] Configuring Git..."
git config --global user.name "Phil Corbett"
git config --global user.email "corbett.phil@gmail.com"
git config --global core.editor "vim"
git config --global init.defaultBranch main

echo "[✔] Git configured."
