#!/bin/bash
# setup_claude_statusline.sh - Install Claude Code status line from this repo
#
# Symlinks dotfiles/claude/statusline-command.sh into ~/.claude/ so git pull
# updates it automatically, then patches ~/.claude/settings.json to point at it.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SRC="$REPO_DIR/dotfiles/claude/statusline-command.sh"
DEST_DIR="$HOME/.claude"
DEST="$DEST_DIR/statusline-command.sh"
SETTINGS="$DEST_DIR/settings.json"

echo "[+] Installing Claude Code status line..."

if [[ ! -f "$SRC" ]]; then
  echo "    Source not found at $SRC, skipping."
  exit 0
fi

if ! command -v jq &> /dev/null; then
  echo "    [!] jq not found; install it first (apt/brew). Skipping."
  exit 0
fi

mkdir -p "$DEST_DIR"
chmod +x "$SRC"

# Back up any pre-existing regular file at the destination so we can safely symlink.
if [[ -e "$DEST" && ! -L "$DEST" ]]; then
  backup="$DEST.backup.$(date +%Y%m%d_%H%M%S)"
  echo "    Backing up existing $DEST -> $backup"
  mv "$DEST" "$backup"
fi

ln -sf "$SRC" "$DEST"
echo "    Symlinked $DEST -> $SRC"

# Patch settings.json to register the status line.
# Create an empty object if the file is missing or not valid JSON.
if [[ ! -f "$SETTINGS" ]] || ! jq empty "$SETTINGS" &> /dev/null; then
  echo "{}" > "$SETTINGS"
fi

tmp=$(mktemp)
jq '.statusLine = {type: "command", command: "bash ~/.claude/statusline-command.sh"}' \
  "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"

echo "    Registered statusLine in $SETTINGS"
echo "[+] Claude Code status line installed."
