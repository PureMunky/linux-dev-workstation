---
name: cld-init
description: Scan a project and generate a .cld/Dockerfile for sandboxed Claude development with project-specific tooling
argument-hint: [base-image]
---

# /cld-init — Generate .cld/Dockerfile for this project

You are initializing a sandboxed Claude development container for the current project. The generated `.cld/Dockerfile` extends `claude-cli-sandbox` (a base image with Node 20, git, jq, tree, and Claude CLI) so that base image updates automatically trickle down.

Follow these steps precisely.

## Step 1: Scan for project markers

Look for these files in the project root (the directory containing the nearest `.git` or the current working directory):

| Marker | Stack | Installation approach |
|--------|-------|-----------------------|
| `go.mod` | Go | `COPY --from=golang:1.22-bookworm /usr/local/go /usr/local/go` + add to PATH |
| `package.json` | Node.js | Already in base image. Add `build-essential` if native deps detected (`node-gyp`, `binding.gyp`) |
| `Cargo.toml` | Rust | Install via rustup: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh -s -- -y` + add to PATH |
| `*.csproj` or `*.sln` | .NET | Install dotnet SDK via Microsoft apt repo. Check `*.csproj` for `<TargetFramework>` to determine SDK version |
| `project.godot` | Godot | Install Godot headless/server build. Note: full editor cannot run headless in container |
| `Makefile` or `CMakeLists.txt` | C/C++ | `build-essential cmake` |
| `pyproject.toml` or `requirements.txt` | Python | `python3 python3-pip python3-venv` |
| `Gemfile` | Ruby | `ruby-full` |
| `pom.xml` or `build.gradle` or `build.gradle.kts` | Java | `default-jdk maven` or `default-jdk gradle` |
| `mix.exs` | Elixir | `elixir erlang-dev` |
| `composer.json` | PHP | `php-cli php-mbstring composer` |

Multiple markers can be present — include **all** detected stacks.

Also scan for:
- `.tool-versions` (asdf) — parse it and install the listed runtimes
- Existing `Dockerfile` or `docker-compose.yml` — inspect for hints about required tooling

## Step 2: Detect linters and formatters

Scan for config files that imply tool needs:

| Config file | Tool |
|-------------|------|
| `.eslintrc*` / `eslint.config.*` | eslint (via npm, already available in Node projects) |
| `.prettierrc*` | prettier (via npm) |
| `.golangci-lint.yml` | golangci-lint |
| Shell scripts or `shellcheck` in CI | `shellcheck` |
| `.rubocop.yml` | rubocop |
| `rustfmt.toml` | rustfmt (comes with rustup) |

## Step 3: Detect infrastructure tools

| Marker | Tool |
|--------|------|
| `**/k8s/`, `**/deploy/`, k8s manifests | kubectl |
| `*.tf` or `terraform/` | terraform CLI |
| `Tiltfile` | tilt |
| `helm/` or `Chart.yaml` | helm |

## Step 4: Generate `.cld/Dockerfile`

Create `.cld/` directory if needed, then write `.cld/Dockerfile`:

```dockerfile
FROM claude-cli-sandbox

USER root

# <Stack name>
<installation commands>

USER claude
```

**Rules:**
- Use `FROM claude-cli-sandbox` by default (or the user-specified base image if `$ARGUMENTS` was provided)
- Always `USER root` before installing, `USER claude` at the end
- Use `apt-get update && apt-get install -y --no-install-recommends ... && rm -rf /var/lib/apt/lists/*` for apt packages
- Group related installs into single RUN commands to minimize layers
- For Go, use multi-stage COPY: `COPY --from=golang:1.22-bookworm /usr/local/go /usr/local/go`
- For Rust, use rustup
- Set `ENV PATH=` for any tools installed to non-standard locations

## Step 5: Generate `.cld/config` (if needed)

Only create `.cld/config` if the project needs extra host mounts:

| Scenario | Mount |
|----------|-------|
| Kubernetes projects | `-v $HOME/.kube:/home/claude/.kube:ro` |
| AWS projects | `-v $HOME/.aws:/home/claude/.aws:ro` |
| NuGet packages (.NET) | `-v $HOME/.nuget:/home/claude/.nuget` |
| Go module cache | `-v $HOME/go/pkg/mod:/home/claude/go/pkg/mod` |

Format:
```bash
CLD_EXTRA_MOUNTS="-v $HOME/.kube:/home/claude/.kube:ro"
CLD_EXTRA_ENV="-e KUBECONFIG=/home/claude/.kube/config"
```

## Step 6: Report and validate

After generating files, print:
1. Summary of detected stacks and tools
2. The generated Dockerfile contents
3. Any config file created

Then run a validation build to confirm the Dockerfile is correct:

```
docker build -t claude-sandbox-<project-name> -f .cld/Dockerfile .cld/
```

If the build fails, diagnose the error, fix the Dockerfile, and retry until it succeeds. Do not consider the task complete until the image builds successfully.

## Step 7: Update the project's CLAUDE.md

After a successful build, update (or create) the project's `CLAUDE.md` to document the sandbox environment. This ensures future Claude sessions know what tools are available inside the container.

Add or update a `## Sandbox Environment` section with:

1. **Available runtimes & versions** — list each language/runtime installed in the Dockerfile (e.g., Go 1.22, .NET 8, Python 3)
2. **Installed CLI tools** — list infrastructure and linting tools added (e.g., kubectl, helm, golangci-lint, shellcheck)
3. **Extra mounts** — if `.cld/config` was created, note which host paths are mounted and why
4. **How to rebuild** — remind that `cld-rebuild` rebuilds the sandbox image

Example section:

```markdown
## Sandbox Environment

This project uses a sandboxed Claude development container (`.cld/Dockerfile`).

**Runtimes:** Go 1.22, Python 3
**CLI tools:** golangci-lint, shellcheck, kubectl, helm
**Host mounts:** `~/.kube` (read-only), `~/go/pkg/mod` (Go module cache)

Rebuild the sandbox image with `cld-rebuild`.
```

**Rules:**
- If `CLAUDE.md` already exists, append or replace only the `## Sandbox Environment` section — do not modify any other content
- If `CLAUDE.md` does not exist, create it with just the `## Sandbox Environment` section
- Keep the section concise — only list what was actually installed, not the full Dockerfile
- When re-running `/cld-init` and the Dockerfile changes, update this section to match

## Important

- **Never overwrite** an existing `.cld/Dockerfile` without asking the user first
- If `.cld/Dockerfile` already exists, show a diff of proposed changes instead
- Keep the Dockerfile minimal — only add what the project actually needs
- Prefer official package managers over manual downloads

## Persisting environment changes

**Any change to the sandbox environment MUST be persisted in `.cld/Dockerfile`.** The container is ephemeral — anything installed at runtime is lost on the next rebuild or restart.

This applies whenever you or the user:
- Install a package (`apt-get install`, `npm install -g`, `pip install`, `go install`, etc.)
- Add a new runtime, SDK, or CLI tool
- Set or modify environment variables (`export`, `ENV`)
- Change PATH or add entries to shell profiles
- Download or copy binaries into the container
- Modify system configuration files

**When this happens:**
1. Make the runtime change so it takes effect immediately
2. Update `.cld/Dockerfile` with the equivalent Dockerfile instruction so the change survives rebuilds
3. Update the `## Sandbox Environment` section in the project's `CLAUDE.md` to reflect the new state

**Do not** defer or skip the Dockerfile update — if a tool is needed now, it will be needed next time. Treat the Dockerfile as the single source of truth for the sandbox environment.
