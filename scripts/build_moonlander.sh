#!/bin/bash

# build_moonlander.sh - Builds Moonlander QMK firmware from keymap source
#
# Usage: ./scripts/build_moonlander.sh
#
# Environment variables:
#   QMK_HOME - Override QMK firmware location (default: ~/zsa_qmk_firmware)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYMAP_SRC="$SCRIPT_DIR/keyboards/moonlander"
QMK_HOME="${QMK_HOME:-$HOME/zsa_qmk_firmware}"
KEYMAP_NAME="custom"

echo "[+] Building Moonlander firmware..."

# Ensure QMK CLI is available
if ! command -v qmk &> /dev/null; then
    echo "[!] QMK CLI not found. Run scripts/setup_moonlander.sh first."
    exit 1
fi

# Clone ZSA's QMK firmware fork if not present (required for Keymapp compatibility)
if [[ ! -d "$QMK_HOME" ]]; then
    echo "Cloning ZSA QMK firmware fork (this may take a while)..."
    git clone --depth 1 --recurse-submodules --shallow-submodules \
        https://github.com/zsa/qmk_firmware.git "$QMK_HOME"
else
    echo "ZSA QMK firmware found at $QMK_HOME"
fi

KEYBOARD="zsa/moonlander/revb"

# Copy keymap files into QMK tree (keymaps are shared across revisions)
KEYMAP_DEST="$QMK_HOME/keyboards/zsa/moonlander/keymaps/$KEYMAP_NAME"
mkdir -p "$KEYMAP_DEST"
cp "$KEYMAP_SRC/keymap.c" "$KEYMAP_DEST/"
cp "$KEYMAP_SRC/config.h" "$KEYMAP_DEST/"
cp "$KEYMAP_SRC/rules.mk" "$KEYMAP_DEST/"
cp "$KEYMAP_SRC/keymap.json" "$KEYMAP_DEST/"

echo "Keymap files copied to $KEYMAP_DEST"

# Compile
echo "Compiling firmware..."
cd "$QMK_HOME"
qmk compile -kb "$KEYBOARD" -km "$KEYMAP_NAME"

# Find and copy the output binary
BIN_FILE=$(find "$QMK_HOME" -maxdepth 1 \( -name "zsa_moonlander_*${KEYMAP_NAME}*.bin" -o -name "zsa_moonlander_*${KEYMAP_NAME}*.hex" \) -print -quit)
if [[ -n "$BIN_FILE" ]]; then
    cp "$BIN_FILE" "$KEYMAP_SRC/"
    echo "[✔] Firmware built: $KEYMAP_SRC/$(basename "$BIN_FILE")"
else
    echo "[!] Build completed but could not find output binary."
    exit 1
fi
