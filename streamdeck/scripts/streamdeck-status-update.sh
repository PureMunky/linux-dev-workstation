#!/bin/bash
# streamdeck-status-update.sh - Updates Stream Deck buttons 5-9 with live status
# Called periodically by systemd timer or manually.
# Requires streamdeck-gui-ng to be running (streamdeck or streamdeck --no-ui).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Button mapping: row 2 = buttons 5-9
# 5=CPU/Mem  6=Docker  7=K8s  8=Disk  9=Network
BUTTONS=(
  "5:status-cpu.sh"
  "6:status-docker.sh"
  "7:status-k8s.sh"
  "8:status-disk.sh"
  "9:status-network.sh"
)

for entry in "${BUTTONS[@]}"; do
  BTN="${entry%%:*}"
  SCRIPT="${entry#*:}"

  OUTPUT=$("$SCRIPT_DIR/$SCRIPT" 2>/dev/null)
  if [[ -z "$OUTPUT" ]]; then
    continue
  fi

  # Scripts output two lines: line 1 = top text, line 2 = bottom text
  # Combine with newline for the button label
  TEXT=$(echo "$OUTPUT" | head -2 | tr '\n' '\n')

  streamdeckc -a SET_TEXT -b "$BTN" --text "$TEXT" 2>/dev/null
done
