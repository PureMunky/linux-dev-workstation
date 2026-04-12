# Plan: Per-Workspace `cld` Development Containers

## Context

The `cld` command currently runs Claude CLI inside a generic container (`node:20-slim` + git/jq/tree). It mounts the current working directory but the container lacks any project-specific tooling — no compilers, no linters, no CLIs. Claude can read/edit files but can't build, test, or run anything. This plan adds support for per-workspace container definitions so that `cld` automatically uses a project-appropriate image when one is available.

## Key Files (Current State)

- `commands/claude-sandboxed` — main `cld` entrypoint script
- `commands/claude-sandboxed-rebuild` — rebuilds the generic image
- `commands/Dockerfile.claude` — generic Claude CLI container image
- `dotfiles/.bashrc` — aliases (`cld`, `cld-rebuild`)
- `setup.sh` — main setup orchestrator

## Implementation Plan

### Step 1: Define a per-project convention — `.cld/Dockerfile`

- Projects opt in by placing a `.cld/Dockerfile` at their root.
- This Dockerfile should `FROM claude-cli-sandbox` (the existing generic image) so it always includes the Claude CLI, then adds project-specific tooling on top.
- An optional `.cld/config` file (sourced as bash) can declare extra mounts and env vars:
  ```bash
  # .cld/config (optional)
  CLD_EXTRA_MOUNTS="-v $HOME/.kube:/home/claude/.kube:ro -v $HOME/.nuget:/home/claude/.nuget"
  CLD_EXTRA_ENV="-e KUBECONFIG=/home/claude/.kube/config"
  ```

### Step 2: Update `commands/claude-sandboxed`

Add project-image detection near the top of the script:

1. Walk up from `$PWD` looking for a `.cld/Dockerfile` (stop at `$HOME` or `/`).
2. If found:
   - Derive an image name: `claude-sandbox-<basename of project dir>`.
   - Check if the image exists (`docker image inspect`). If not, build it automatically.
   - Source `.cld/config` if it exists to pick up extra mounts/env vars.
   - Use the project-specific image name instead of `claude-cli-sandbox`.
3. If not found: use the existing generic `claude-cli-sandbox` image (current behavior, unchanged).

Add the extra mounts and env vars from `.cld/config` to the `docker run` command.

### Step 3: Update `commands/claude-sandboxed-rebuild`

- If run inside a project with `.cld/Dockerfile`: rebuild that project's image (and the base image first if needed).
- If run outside any project: rebuild only the generic base image (current behavior).
- Add a `--all` flag to rebuild the base + all known project images.

### Step 4: Create `.cld/Dockerfile` for this workspace

```dockerfile
FROM claude-cli-sandbox

USER root

# Shell tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    shellcheck \
    && rm -rf /var/lib/apt/lists/*

# Go (for validating go.txt packages)
COPY --from=golang:1.22-bookworm /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

# kubectl + helm (for validating k8s scripts)
RUN curl -fsSL https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

USER claude
```

### Step 5: Add `scripts/setup_cld.sh`

A setup script that:
1. Builds the generic `claude-cli-sandbox` base image from `commands/Dockerfile.claude`.
2. Optionally builds the workspace-specific image if `.cld/Dockerfile` exists in the repo root.

### Step 6: Update `setup.sh`

Add a call to `./scripts/setup_cld.sh` after Docker setup completes.

## File Summary

| File | Action | Description |
|------|--------|-------------|
| `commands/claude-sandboxed` | **Modify** | Add `.cld/Dockerfile` discovery, project image selection, config sourcing |
| `commands/claude-sandboxed-rebuild` | **Modify** | Support project-specific and `--all` rebuilds |
| `.cld/Dockerfile` | **Create** | This workspace's dev container (shellcheck, Go, kubectl) |
| `.cld/config` | **Create** | Optional extra mounts/env for this workspace |
| `scripts/setup_cld.sh` | **Create** | Build base + project images during setup |
| `setup.sh` | **Modify** | Call `setup_cld.sh` and `setup_claude_skills.sh` |
| `skills/cld-init/SKILL.md` | **Create** | `/cld-init` skill — scan project and generate `.cld/Dockerfile` |
| `scripts/setup_claude_skills.sh` | **Create** | Symlink skills from repo into `~/.claude/skills/` |

### Step 7: Add Claude Code skills system

- Create `skills/cld-init/SKILL.md` — a Claude Code skill that scans a project for language/framework markers and generates `.cld/Dockerfile` and `.cld/config` automatically.
- Create `scripts/setup_claude_skills.sh` — symlinks each skill from `skills/<name>/SKILL.md` into `~/.claude/skills/<name>/SKILL.md` so they are available globally. Uses symlinks so `git pull` auto-updates skills without re-running setup.
- Update `setup.sh` to call `setup_claude_skills.sh` after `setup_cld.sh`.

### Step 8: Update documentation

- Update `CLAUDE.md` with cld per-project container and skills documentation.

## Verification

1. **Generic fallback**: `cd /tmp && cld "echo hello"` — should use the base `claude-cli-sandbox` image as before.
2. **Project detection**: `cd /workspace && cld "which shellcheck && go version"` — should use the workspace-specific image and find the tools.
3. **Auto-build**: Delete the project image, run `cld` — it should rebuild automatically.
4. **Rebuild**: Run `cld-rebuild` from inside the workspace — should rebuild the project image. Run from `/tmp` — should rebuild only the base.
5. **Setup**: Run `./scripts/setup_cld.sh` — should build both images without error.
6. **Skills installation**: Run `./scripts/setup_claude_skills.sh` — `~/.claude/skills/cld-init/SKILL.md` should be a symlink.
7. **Skill invocation**: Run `/cld-init` inside any project — should scan markers and generate `.cld/Dockerfile`.
