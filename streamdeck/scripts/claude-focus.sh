#!/bin/bash

# claude-focus.sh - Switches focus to an existing Claude tmux session
# Usage: claude-focus.sh <session_number>

SESSION="claude-$1"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    open -a WezTerm
  else
    wmctrl -a WezTerm 2>/dev/null || true
  fi
  tmux switch-client -t "$SESSION" 2>/dev/null || \
    wezterm start -- tmux attach -t "$SESSION"
else
  echo "No Claude session $1 running. Use launch button first."
fi
