#!/bin/bash

# build_moonlander.sh - Builds Moonlander QMK firmware from keymap source
#
# Usage: ./scripts/build_moonlander.sh
#
# Environment variables:
#   QMK_HOME - Override QMK firmware location (default: ~/.cache/qmk_firmware)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYMAP_SRC="$SCRIPT_DIR/keyboards/moonlander"
QMK_HOME="${QMK_HOME:-$HOME/.cache/qmk_firmware}"
KEYMAP_NAME="custom"

echo "[+] Building Moonlander firmware..."

# Ensure QMK CLI is available
if ! command -v qmk &> /dev/null; then
    echo "[!] QMK CLI not found. Run scripts/setup_moonlander.sh first."
    exit 1
fi

# Clone QMK firmware if not present
if [[ ! -d "$QMK_HOME" ]]; then
    echo "Cloning QMK firmware (this may take a while)..."
    git clone --depth 1 --recurse-submodules --shallow-submodules \
        https://github.com/qmk/qmk_firmware.git "$QMK_HOME"
else
    echo "QMK firmware found at $QMK_HOME"
fi

# Copy keymap files into QMK tree
KEYMAP_DEST="$QMK_HOME/keyboards/moonlander/keymaps/$KEYMAP_NAME"
mkdir -p "$KEYMAP_DEST"
cp "$KEYMAP_SRC/keymap.c" "$KEYMAP_DEST/"
cp "$KEYMAP_SRC/config.h" "$KEYMAP_DEST/"
cp "$KEYMAP_SRC/rules.mk" "$KEYMAP_DEST/"

echo "Keymap files copied to $KEYMAP_DEST"

# Compile
echo "Compiling firmware..."
cd "$QMK_HOME"
qmk compile -kb moonlander -km "$KEYMAP_NAME"

# Find and copy the output binary
BIN_FILE=$(find "$QMK_HOME" -maxdepth 1 \( -name "moonlander_${KEYMAP_NAME}*.bin" -o -name "moonlander_${KEYMAP_NAME}*.hex" \) -print -quit)
if [[ -n "$BIN_FILE" ]]; then
    cp "$BIN_FILE" "$KEYMAP_SRC/"
    echo "[✔] Firmware built: $KEYMAP_SRC/$(basename "$BIN_FILE")"
else
    echo "[!] Build completed but could not find output binary."
    exit 1
fi
