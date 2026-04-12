#!/bin/bash

# claude-status.sh - Updates Stream Deck button to reflect Claude session status
# Usage: claude-status.sh <session_number> <status>
# status: in_progress | needs_attention | complete

SESSION_NUM="$1"
STATUS="$2"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/streamdeck"
mkdir -p "$STATE_DIR"

# Write status to state file
echo "$STATUS" > "$STATE_DIR/claude-${SESSION_NUM}.status"

# Map status to display
case "$STATUS" in
  in_progress)     LABEL="⏳ C${SESSION_NUM}" ; COLOR="#FFA500" ;;
  needs_attention) LABEL="⚠ C${SESSION_NUM}"  ; COLOR="#FF0000" ;;
  complete)        LABEL="✅ C${SESSION_NUM}" ; COLOR="#00FF00" ;;
esac

# Update the streamdeck button text via config rewrite
CONFIG="$HOME/.streamdeck_ui.json"
if command -v python3 &> /dev/null && [[ -f "$CONFIG" ]]; then
  python3 - "$CONFIG" "$SESSION_NUM" "$STATUS" <<'PYEOF'
import json, sys
config_path, sess, status = sys.argv[1], sys.argv[2], sys.argv[3]
with open(config_path) as f:
    cfg = json.load(f)

# Status button indices: session 1 = keys 6,7,8; session 2 = keys 11,12,13
status_buttons = {
    "1": {"6": "in_progress", "7": "needs_attention", "8": "complete"},
    "2": {"11": "in_progress", "12": "needs_attention", "13": "complete"},
}
icons = {"in_progress": "\u23f3", "needs_attention": "\u26a0", "complete": "\u2705"}

for serial in cfg.get("state", {}):
    buttons = cfg["state"][serial].get("buttons", {}).get("0", {})
    for key, st in status_buttons.get(sess, {}).items():
        if key in buttons:
            icon = icons[st]
            # Active status gets highlighted, others get dimmed
            if st == status:
                buttons[key]["text"] = f"{icon} C{sess} \u25c0"
            else:
                buttons[key]["text"] = f"{icon} C{sess}"

with open(config_path, "w") as f:
    json.dump(cfg, f, indent=2)
PYEOF
fi

echo "Claude $SESSION_NUM status: $STATUS"
