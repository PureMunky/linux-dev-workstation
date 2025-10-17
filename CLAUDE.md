# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a cross-platform development workstation setup repository designed for **Ubuntu-based Linux** and **macOS** systems, targeting Kubernetes/.NET development. The repository uses a modular script-based approach where:

- `setup.sh` - Main orchestration script that detects OS and executes all setup components
- `scripts/` - Individual setup scripts with cross-platform support (auto-detect Linux vs macOS)
- `package_lists/` - Text files containing package names for different package managers
  - `apt.txt` - Ubuntu/Debian packages
  - `brew.txt` - macOS Homebrew packages
  - `go.txt` - Go packages (cross-platform)
  - `npm.txt` - npm packages (cross-platform)
- `dotfiles/` - Configuration files that get symlinked to the home directory

## Platform Support

**Supported Operating Systems:**
- Ubuntu-based Linux distributions (uses `apt`)
- macOS (uses Homebrew)

**Automatic OS Detection:**
All scripts automatically detect the operating system using `uname -s` and install the appropriate packages/binaries:
- Linux → Downloads `linux/amd64` or `linux/arm64` binaries, uses `apt` package manager
- macOS → Downloads `darwin/amd64` or `darwin/arm64` binaries, uses `brew` package manager

## Setup Commands

**Initial Setup:**
```bash
# Make scripts executable and run full setup
find . -name "*.sh" -exec chmod +x {} \;
./setup.sh
```

**Individual Component Setup:**
Scripts can be run independently if needed (all scripts are cross-platform):
- `./scripts/install_apt_packages.sh` - Core system packages (apt on Linux, brew on macOS)
- `./scripts/install_go_packages.sh` - Go development tools
- `./scripts/setup_git.sh` - Git configuration (sets user: Phil Corbett)
- `./scripts/setup_kubernetes.sh` - kubectl, k9s, kind, helm, kubeval, yamllint
- `./scripts/setup_dotnet.sh` - .NET SDK (apt on Linux, brew cask on macOS)
- `./scripts/setup_docker.sh` - Docker Engine (Linux) or Docker Desktop (macOS)
- `./scripts/setup_vscode.sh` - Visual Studio Code setup
- `./scripts/install_argocd.sh` - ArgoCD CLI
- `./scripts/setup_tilt.sh` - Tilt development tool
- `./scripts/setup_node.sh` - Node.js via nvm (cross-platform)
- `./scripts/install_npm_packages.sh` - Global npm packages

## Package Management

Package lists are maintained in `package_lists/`:
- `apt.txt` - System packages for Ubuntu/Debian via apt
- `brew.txt` - System packages for macOS via Homebrew
- `go.txt` - Go packages via `go install` (cross-platform)
- `npm.txt` - Global npm packages (cross-platform)

## Platform-Specific Behavior

**Docker:**
- **Linux**: Installs Docker Engine via apt, adds user to docker group
- **macOS**: Installs Docker Desktop via Homebrew cask

**.NET SDK:**
- **Linux**: Installs via Microsoft's apt repository
- **macOS**: Installs via Homebrew cask

**VS Code:**
- **Linux**: Installs via Microsoft's apt repository
- **macOS**: Installs via Homebrew cask

**Binary Tools** (kubectl, k9s, kind, argocd, kubeval):
- Automatically downloads the correct binary for the detected OS and architecture (amd64/arm64)

## Development Environment

The setup configures a comprehensive development environment with:
- Kubernetes development tools (kubectl, k9s, kind, helm)
- Container development (Docker Engine/Desktop, Tilt)
- Multiple language runtimes (Go, .NET, Node.js)
- Code quality tools (yamllint, kubeval)
- Git configuration with vim as the default editor

All dotfiles are automatically symlinked from `dotfiles/` to `$HOME/` during setup.