---
name: autopilot
description: Autonomous improvement loop — scan, fix, test, commit. Run while the user is away from the computer.
argument-hint: [duration e.g. 30m, 1h, 2h]
---

# /autopilot — Autonomous Improvement Loop

The user is stepping away. Your job is to continuously improve the current project by discovering issues, making changes, validating them, and committing — one atomic improvement at a time.

## Configuration

- **Duration**: Work for the time specified in `$ARGUMENTS` (default: `1h`). Parse values like `30m`, `1h`, `2h`. When time is up, finish your current improvement cycle (don't abandon mid-change) and stop.
- **Max retries per change**: If a change breaks tests or build, attempt to fix it up to **3 times**. If still broken after 3 attempts, fully revert and move on.

## What to improve

Auto-discover work by scanning the project. Prioritize in this order:

1. **Broken things first** — failing tests, build errors, lint errors
2. **Security & dependency issues** — outdated deps with known vulnerabilities, insecure patterns
3. **Code quality** — dead code removal, simplifying complex functions, fixing type errors, resolving TODOs/FIXMEs
4. **Test coverage** — add missing tests for untested code paths, improve edge case coverage
5. **Documentation** — add/update docstrings and inline comments where logic is non-obvious
6. **Aligned improvements** — small features, refactors, or enhancements that align directionally with the project's current implementation and goals

**Important constraints:**
- Never contradict or fight the existing implementation — work *with* the codebase, not against it
- Don't introduce speculative abstractions or over-engineer
- Each change should be small, focused, and independently valuable
- Read and understand code before modifying it

## What you can touch

**Allowed:**
- Source code files
- Test files
- Documentation files
- Build configuration (Makefile, CMakeLists, package.json scripts, etc.)
- Linter and formatter configs
- Dependency files (package.json, go.mod, requirements.txt, etc.)

**Off-limits:**
- CI/CD pipelines (.github/workflows, .gitlab-ci.yml, Jenkinsfile, etc.)
- Dockerfiles and container configs (unless inside `.cld/`)
- Project directory structure (don't move or rename directories)
- License files
- Git configuration

## The Loop

For each improvement, follow this cycle strictly:

### 1. Discover

Scan for the next most valuable thing to fix or improve. Methods:
- Run linters/formatters if configured (check package.json scripts, Makefile targets, etc.)
- Run the test suite to find failures
- Grep for `TODO`, `FIXME`, `HACK`, `XXX`
- Look for functions with no test coverage
- Check for outdated dependencies (`npm outdated`, `go list -m -u all`, etc.)
- Read code and identify quality improvements

Pick **one** focused improvement to make.

### 2. Understand

Before changing anything:
- Read all files you plan to modify
- Understand the surrounding context and intent
- Check if there are existing tests for the area you're touching
- Identify how to validate your change (which tests, which build commands)

### 3. Implement

Make the change. Keep it minimal and focused — one concern per cycle.

### 4. Validate

Run the project's test and build commands to verify your change is correct:

**Detecting test/build commands** (check in order):
- `CLAUDE.md` — look for documented test/build commands
- `Makefile` / `Justfile` — look for `test`, `build`, `check`, `lint` targets
- `package.json` — look for `test`, `build`, `lint` scripts
- Language conventions — `go test ./...`, `cargo test`, `dotnet test`, `pytest`, etc.

Run:
1. **Build** (if applicable) — the project must compile/bundle
2. **Tests** — the full test suite must pass
3. **Lint** (if available) — no new lint violations

If **any step fails**:
- Diagnose the failure
- Attempt a fix (up to 3 retries total for this change)
- If still failing after 3 attempts: **revert all changes** for this improvement and log the failure
- Move on to the next improvement

### 5. Commit

Only after validation passes:
- Stage only the files related to this improvement
- Write a clear, descriptive commit message explaining *what* and *why*
- Use conventional commit style if the project already does, otherwise write plain English

### 6. Log

After each cycle (success or failure), append an entry to `.autopilot-log.md` in the project root:

```markdown
## [HH:MM] <Short title>

**Status**: completed | reverted | skipped
**Category**: bug-fix | test-coverage | code-quality | documentation | security-deps | feature | config
**Files changed**: file1.py, file2.py
**What**: One-line description of the change
**Why**: One-line rationale
**Validation**: Tests passed (52/52), build OK, lint clean
**Cycle time**: ~Xm (e.g., ~8m)
```

For reverted changes, include what went wrong:
```markdown
**Failure reason**: Test `test_auth_flow` failed — TypeError on line 42 after 3 fix attempts
```

### 7. Repeat

Go back to step 1. Continue until:
- The time limit is reached (finish current cycle first)
- You run out of meaningful improvements to make
- You encounter a systemic issue that blocks further work

## When finished

1. **Write the final log entry** — add a summary block at the end of `.autopilot-log.md`:

```markdown
---
## Session Summary

**Duration**: 1h (10:00 - 11:00)
**Commits**: 7 completed, 2 reverted
**Areas touched**: auth module, API tests, dependency updates
**Notable**: Upgraded express from 4.18 to 4.21, added 12 new test cases

### Time Breakdown

| Category       | Time  | Cycles | Commits |
|----------------|-------|--------|---------|
| Bug fixes      | 18m   | 2      | 2       |
| Test coverage  | 15m   | 2      | 2       |
| Code quality   | 12m   | 2      | 1 (+1 reverted) |
| Documentation  | 8m    | 1      | 1       |
| Security/deps  | 7m    | 1      | 1       |
| **Total**      | **60m** | **8** | **7**  |
```

Compute the time breakdown by summing the **Cycle time** values from each log entry, grouped by **Category**. Include every category that had at least one cycle.

2. **Print a brief summary** to the user (include the time breakdown):

> Autopilot session complete (1h). Made 7 commits, reverted 2 failed attempts.
> Time spent: bug fixes 18m, tests 15m, code quality 12m, docs 8m, deps 7m.
> Key changes: [2-3 sentence highlight of most impactful work].
> Full details in `.autopilot-log.md`.

## Important

- **Never force-push or rewrite history** — only create new commits
- **Never commit secrets, credentials, or .env files**
- **If the project has no tests or build system**, focus only on low-risk changes (docs, linting, dead code removal) and warn in the summary
- **If you're unsure whether a change is safe**, skip it — err on the side of caution
- **Respect .gitignore** — don't commit generated or ignored files
- Clean up `.autopilot-log.md` formatting but do NOT delete it — the user will review it
