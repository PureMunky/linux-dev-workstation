# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Linux development workstation setup repository designed for Ubuntu-based systems targeting Kubernetes/.NET development. The repository uses a modular script-based approach where:

- `setup.sh` - Main orchestration script that executes all setup components
- `scripts/` - Individual setup scripts for different tools and environments
- `package_lists/` - Text files containing package names for different package managers
- `dotfiles/` - Configuration files that get symlinked to the home directory

## Setup Commands

**Initial Setup:**
```bash
# Make scripts executable and run full setup
find . -name "*.sh" -exec chmod +x {} \;
./setup.sh
```

**Individual Component Setup:**
Scripts can be run independently if needed:
- `./scripts/install_apt_packages.sh` - Core system packages
- `./scripts/install_go_packages.sh` - Go development tools
- `./scripts/setup_git.sh` - Git configuration (sets user: Phil Corbett)
- `./scripts/setup_kubernetes.sh` - kubectl, k9s, kind, helm, kubeval, yamllint
- `./scripts/setup_dotnet.sh` - .NET CLI tools
- `./scripts/setup_docker.sh` - Docker installation and configuration
- `./scripts/setup_vscode.sh` - Visual Studio Code setup
- `./scripts/install_argocd.sh` - ArgoCD CLI
- `./scripts/setup_tilt.sh` - Tilt development tool
- `./scripts/setup_node.sh` - Node.js via nvm
- `./scripts/install_npm_packages.sh` - Global npm packages

## Package Management

Package lists are maintained in `package_lists/`:
- `apt.txt` - System packages via apt
- `go.txt` - Go packages via `go install`
- `npm.txt` - Global npm packages

## Development Environment

The setup configures a comprehensive development environment with:
- Kubernetes development tools (kubectl, k9s, kind, helm)
- Container development (Docker, Tilt)
- Multiple language runtimes (Go, .NET, Node.js)
- Code quality tools (yamllint, kubeval)
- Git configuration with vim as the default editor

All dotfiles are automatically symlinked from `dotfiles/` to `$HOME/` during setup.