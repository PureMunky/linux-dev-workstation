#!/bin/bash

# flash_moonlander.sh - Flashes pre-built Moonlander firmware via Keymapp
#
# Usage: ./scripts/flash_moonlander.sh [firmware.bin]
#
# If no firmware file is given, looks for the most recently built binary in
# keyboards/moonlander/.  Keymapp provides a GUI for the flashing process —
# this script locates the firmware and launches Keymapp with it.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYMAP_SRC="$SCRIPT_DIR/keyboards/moonlander"

# Resolve firmware file
if [[ -n "$1" ]]; then
    FIRMWARE="$1"
else
    FIRMWARE=$(find "$KEYMAP_SRC" -maxdepth 1 \( -name "*.bin" -o -name "*.hex" \) | sort | tail -n 1)
fi

if [[ -z "$FIRMWARE" || ! -f "$FIRMWARE" ]]; then
    echo "[!] No firmware file found. Run scripts/build_moonlander.sh first, or pass a path:"
    echo "    $0 path/to/firmware.bin"
    exit 1
fi

FIRMWARE="$(realpath "$FIRMWARE")"
echo "[+] Firmware: $FIRMWARE"

# Ensure Keymapp is available
if ! command -v keymapp &> /dev/null; then
    echo "[!] Keymapp not found. Run scripts/setup_moonlander.sh to install it."
    exit 1
fi

echo ""
echo "Launching Keymapp to flash firmware."
echo "In Keymapp: click 'Flash from file', select the firmware, then follow the prompts."
echo ""
echo "Firmware path (copied to clipboard if xclip is available):"
echo "  $FIRMWARE"

# Try to copy path to clipboard for convenience
if command -v xclip &> /dev/null; then
    echo -n "$FIRMWARE" | xclip -selection clipboard
    echo "  (copied to clipboard)"
fi

echo ""
keymapp &
echo "[+] Keymapp launched."
