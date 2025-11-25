# Cross-Platform Dev Workstation Setup

Automated development environment setup for **Ubuntu Linux** and **macOS**, targeting Kubernetes and .NET development.

## Features

- **Cross-platform**: Automatically detects your OS (Linux/macOS) and installs the appropriate tools
- **Comprehensive**: Kubernetes tools, Docker, .NET SDK, VS Code, Node.js, Go tools, and more
- **Modular**: Run the full setup or individual component scripts
- **Architecture-aware**: Supports both x86_64 (amd64) and ARM64 architectures

## Quick Start

```bash
# Make scripts executable
find . -name "*.sh" -exec chmod +x {} \;

# Run full setup
./setup.sh
```

## What Gets Installed

### Development Tools
- **Kubernetes**: kubectl, k9s, kind, helm, kubeval, yamllint
- **Containers**: Docker Engine (Linux) / Docker Desktop (macOS), Tilt
- **Languages**: .NET SDK, Go, Node.js (via nvm)
- **IDE**: Visual Studio Code with extensions
- **CLI Tools**: ArgoCD CLI, various Go tools
- **System Maintenance**: Automatic security updates (unattended-upgrades on Linux, softwareupdate on macOS)

### Platform-Specific Installation
- **Linux (Ubuntu)**: Uses `apt` package manager + direct binary downloads
- **macOS**: Uses Homebrew (auto-installs if not present) + direct binary downloads

## Requirements

- **Linux**: Ubuntu-based distribution with sudo access
- **macOS**: macOS with ability to install Homebrew

## Individual Components

You can run individual setup scripts if you only need specific tools:

```bash
./scripts/install_apt_packages.sh  # Base packages (apt/brew)
./scripts/setup_auto_updates.sh    # Automatic system updates
./scripts/setup_docker.sh          # Docker
./scripts/setup_kubernetes.sh      # Kubernetes tools
./scripts/setup_dotnet.sh          # .NET SDK
./scripts/setup_vscode.sh          # VS Code
./scripts/setup_node.sh            # Node.js via nvm
# ... and more in scripts/
```

## Package Lists

Package definitions are maintained in `package_lists/`:
- `apt.txt` - Linux packages
- `brew.txt` - macOS packages
- `go.txt` - Go packages (cross-platform)
- `npm.txt` - npm packages (cross-platform)

## Customization

- **Git config**: Edit `scripts/setup_git.sh` to change user name/email
- **VS Code extensions**: Modify `scripts/setup_vscode.sh` to add/remove extensions
- **Packages**: Add/remove packages in the `package_lists/` files