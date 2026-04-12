#!/bin/bash
# setup_claude_skills.sh - Install Claude Code skills from this repo
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

echo "[+] Installing Claude Code skills..."

if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "    No skills directory found at $SKILLS_SRC, skipping."
  exit 0
fi

mkdir -p "$SKILLS_DEST"

for skill_dir in "$SKILLS_SRC"/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name=$(basename "$skill_dir")

  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    echo "    [!] Skipping $skill_name (no SKILL.md found)"
    continue
  fi

  dest="$SKILLS_DEST/$skill_name"
  mkdir -p "$dest"

  # Symlink so git pull auto-updates skills without re-running setup
  ln -sf "$skill_dir/SKILL.md" "$dest/SKILL.md"
  echo "    Installed skill: $skill_name"
done

echo "[+] Claude Code skills installed."
