#!/bin/bash

# claude-launch.sh - Launches a Claude Code session in a named tmux session
# Usage: claude-launch.sh <session_number>

SESSION="claude-$1"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session $SESSION already exists. Focusing..."
else
  tmux new-session -d -s "$SESSION" -x 200 -y 50
  tmux send-keys -t "$SESSION" "claude" Enter
fi

# Focus the terminal
if [[ "$(uname -s)" == "Darwin" ]]; then
  open -a WezTerm
else
  wmctrl -a WezTerm 2>/dev/null || true
fi
tmux switch-client -t "$SESSION" 2>/dev/null || \
  wezterm start -- tmux attach -t "$SESSION"
