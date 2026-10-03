# Repository Overview

`linux-dev-workstation` sets up a whole development workstation on
**Ubuntu-based Linux** or **macOS** for Kubernetes and .NET work. It also
holds the configuration for the peripherals and AI tooling around it: a ZSA
Moonlander keyboard, an Elgato Stream Deck, and Claude Code.

Related docs:
- [Keyboard Layouts](KEYBOARD_LAYOUTS.md): Moonlander layers, WezTerm keys, Stream Deck grids
- [Automatic Updates](AUTO_UPDATES.md): unattended-upgrades / softwareupdate details
- [`../readme.md`](../readme.md): quick start

---

## Directory map

```
linux-dev-workstation/
├── setup.sh                  # Entry point: detects OS, runs every setup step in order
├── scripts/                  # One script per component (all cross-platform)
├── package_lists/            # Plain-text package lists (apt, brew, go, npm)
├── dotfiles/                 # Symlinked into $HOME by setup.sh
│   ├── .bashrc               #   aliases, PATH, git/k8s prompt helpers
│   ├── .gitconfig            #   user, vim editor, short aliases
│   ├── .wezterm.lua          #   terminal theme, font, pane key bindings
│   └── claude/statusline-command.sh   # Claude Code status line
├── commands/                 # User-facing CLI wrappers (cld, cld-rebuild, ralph)
├── skills/                   # Claude Code skills, symlinked to ~/.claude/skills/
├── keyboards/moonlander/     # QMK firmware source for the ZSA Moonlander
├── keymap.txt                # Printable Moonlander reference (generated)
├── streamdeck/               # Stream Deck layouts + status/launcher scripts
├── .cld/                     # This repo's own Claude sandbox customization
└── docs/                     # This documentation
```

---

## How `setup.sh` works

`setup.sh` makes every `*.sh` executable, checks `uname -s`, and runs these
steps in order. A failed step stops the run (`set -e`).

| # | Step | Script | Linux | macOS |
|---|------|--------|-------|-------|
| 1 | Core packages | `install_apt_packages.sh` | `apt` + `apt.txt` | Homebrew (auto-installed) + `brew.txt` |
| 2 | Auto updates | `setup_auto_updates.sh` | unattended-upgrades | softwareupdate / App Store |
| 3 | Go tools | `install_go_packages.sh` | `go install` from `go.txt` | same |
| 4 | Dotfiles | *(inline)* | `ln -sf dotfiles/.* ~/` | same |
| 5 | Git | `setup_git.sh` | global git config | same |
| 6 | Kubernetes | `setup_kubernetes.sh` | kubectl, k9s, kind, helm, kubeval, yamllint | same (darwin binaries) |
| 7 | .NET | `setup_dotnet.sh` | Microsoft apt repo | brew cask |
| 8 | Docker | `setup_docker.sh` | Docker Engine + `docker` group | Docker Desktop cask |
| 9 | Claude sandbox | `setup_cld.sh` | builds `claude-cli-sandbox` images | same |
| 10 | Claude skills | `setup_claude_skills.sh` | symlinks `skills/*` → `~/.claude/skills/` | same |
| 11 | Claude status line | `setup_claude_statusline.sh` | symlinks + patches `~/.claude/settings.json` | same |
| 12 | VS Code | `setup_vscode.sh` | Microsoft apt repo + extensions | brew cask |
| 13 | WezTerm | `setup_wezterm.sh` | WezTerm apt repo | brew cask |
| 14 | Stream Deck | `setup_streamdeck.sh` | streamdeck-gui-ng (venv) | hidapi + streamdeck-gui-ng |
| — | Moonlander | `setup_moonlander.sh` | *commented out*; run it yourself | |
| 15 | ArgoCD CLI | `install_argocd.sh` | binary download | same |
| 16 | Tilt | `setup_tilt.sh` | install script | same |
| 17 | Node.js | `setup_node.sh` | nvm (pinned v0.40.7) | same |
| 18 | npm globals | `install_npm_packages.sh` | `npm i -g` from `npm.txt` | same |

At the end the script runs `exec bash` to reload the shell.

**Re-running updates things.** The binary tools (kubectl, k9s, kind, helm,
kubeval, argocd) and the .NET SDK skip the "already installed" check, so each
run of `setup.sh` fetches and overwrites them with the latest release.

**Architecture-aware.** Binary downloads choose `linux|darwin` ×
`amd64|arm64` from `uname`.

---

## Package lists

| File | Manager | Contents |
|------|---------|----------|
| `apt.txt` | apt | git, curl, wget, zsh, vim, tmux, build-essential, python3-pip, ca-certificates, apt-transport-https, software-properties-common, jq, htop, golang-go |
| `brew.txt` | Homebrew | git, curl, wget, zsh, vim, tmux, python3, jq, htop, go, yamllint |
| `go.txt` | `go install` | `ctlptl` (Tilt's cluster controller) |
| `npm.txt` | `npm -g` | `@anthropic-ai/claude-code` |

To add a tool, add a line to the matching list and re-run the installer script.

---

## Dotfiles

| File | Highlights |
|------|------------|
| `.bashrc` | Aliases: `k`=kubectl, `kp`=all pods, `d`=dotnet, `gs/ga/gd/gac/gpush/gpull`, `co`=`code .`, `cl`=`claude --permission-mode auto`, `cld`/`cld-rebuild`/`cldt`/`clds` (sandbox), `ralph`. Adds .NET, Go, and nvm to PATH. Git branch and kube-context prompt helpers. |
| `.gitconfig` | Phil Corbett identity, `vim` editor, `autocrlf=input`, `main` default branch, aliases `co/br/ci/st`. |
| `.wezterm.lua` | Monokai Pro (Gogh), JetBrains Mono 11, WebGPU at 120 fps, Wayland, 95% opacity, pane split/move/close keys ([details](KEYBOARD_LAYOUTS.md#wezterm-key-bindings)). |
| `claude/statusline-command.sh` | Claude Code status line showing model, cwd, and context-window usage, built from the JSON on stdin with `jq`. |

> Several aliases hard-code `~/workspace/linux-dev-workstation/`, so clone the
> repo to that path or edit `.bashrc`.

---

## Claude Code tooling

### `cld`: sandboxed Claude CLI (`commands/claude-sandboxed`)
Runs Claude Code in a throwaway Docker container. Only the current directory
and a fresh copy of `~/.claude` are mounted, and everything is wiped on exit.

- Base image: `claude-cli-sandbox`, built from `commands/Dockerfile.claude`.
- **Per-project images:** if a `.cld/Dockerfile` exists (`cld` searches up
  from the current directory), it builds and uses `claude-sandbox-<project-dir>`.
- **`.cld/config`** (sourced as bash) can set `CLD_EXTRA_MOUNTS` and
  `CLD_EXTRA_ENV`. This repo's own `.cld/` adds shellcheck, Go 1.22, and
  kubectl, and mounts `~/.kube` read-only.
- `cld-rebuild` rebuilds the base and current project images. `--all` rebuilds
  every project image it finds.
- `cldt` / `clds` start a session in tmux / list tmux sessions.

### `ralph` (`commands/ralph`)
"Read → Analyze → Loop → Produce." An autonomous loop that keeps calling
Claude with fresh context plus the current project state until Claude marks
the project done. Usage: `ralph "build me a CLI todo app"` or
`ralph -f prompt.txt`.

### Skills (`skills/`)
| Skill | What it does |
|-------|--------------|
| `/cld-init` | Scans a project for language/framework markers and writes a matching `.cld/Dockerfile` |
| `/autopilot [30m\|1h\|2h]` | Autonomous scan → fix → test → commit loop for when you're away |

---

## Peripherals

### ZSA Moonlander (`keyboards/moonlander/`)
Custom QMK firmware: QWERTY base, a Nav/Function layer, an OS-aware Shortcuts
layer, a Space+Enter Linux⇄Mac toggle with audio feedback, and 10 RGB theme
options. Build with `build_moonlander.sh` (ZSA's QMK fork) and flash with
`flash_moonlander.sh` (Keymapp).
**Full layer diagrams: [Keyboard Layouts](KEYBOARD_LAYOUTS.md#zsa-moonlander).**

### Stream Deck (`streamdeck/`)
- `config.json`: default Linux dev layout (launchers, live system status, system controls).
- `configs/work-template.json`: macOS work layout (chat/mail apps plus two Claude session rows).
- `scripts/status-*.sh`: compact status text (CPU/mem, Docker, K8s, disk, network). `--detail` opens a full view.
- `scripts/streamdeck-status-update.sh`: refreshes the status buttons on a timer.
- `scripts/claude-{launch,status,focus}.sh`: start, flag, and focus Claude tmux sessions.

**Grid diagrams: [Keyboard Layouts](KEYBOARD_LAYOUTS.md#stream-deck-button-grids).**

---

## Common customizations

| Want to… | Edit |
|----------|------|
| Change git identity | `scripts/setup_git.sh`, `dotfiles/.gitconfig` |
| Add or remove packages | `package_lists/*.txt` |
| Add VS Code extensions | `scripts/setup_vscode.sh` |
| Change terminal look or keys | `dotfiles/.wezterm.lua` |
| Remap the keyboard | `keyboards/moonlander/keymap.c`, then rebuild, flash, and regenerate `keymap.txt` |
| Add tooling to a project's Claude sandbox | That project's `.cld/Dockerfile` (or run `/cld-init`) |
