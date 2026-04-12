#!/bin/bash

# setup_streamdeck.sh - Installs streamdeck-gui-ng and configures Stream Deck
# Uses streamdeck-gui-ng (maintained fork of streamdeck-ui) which supports
# Python 3.12+, modern Pillow, and PySide6.

set -e

OS="$(uname -s)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[+] Installing Stream Deck support..."

VENV_DIR="$HOME/.local/share/pipx/venvs/streamdeck-ui"

if [[ "$OS" == "Linux" ]]; then
  echo "Installing Linux dependencies..."
  sudo apt update
  sudo apt install -y libhidapi-libusb0 libhidapi-dev libhidapi-hidraw0 \
    libudev-dev libusb-1.0-0-dev \
    python3-pip python3-venv python3-dev \
    libxcb-xinerama0 libjpeg-dev zlib1g-dev libffi-dev

  # Add udev rule for Stream Deck USB access
  echo "Configuring udev rules..."
  echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/70-streamdeck.rules
  sudo udevadm control --reload-rules && sudo udevadm trigger

  if ! command -v streamdeck &> /dev/null; then
    echo "Installing streamdeck-gui-ng into venv..."
    mkdir -p "$VENV_DIR" "$HOME/.local/bin"
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install streamdeck-gui-ng
    ln -sf "$VENV_DIR/bin/streamdeck" "$HOME/.local/bin/streamdeck"
    ln -sf "$VENV_DIR/bin/streamdeckc" "$HOME/.local/bin/streamdeckc"
  else
    echo "streamdeck-gui-ng already installed."
  fi

elif [[ "$OS" == "Darwin" ]]; then
  echo "Installing macOS dependencies..."
  brew install hidapi python-tk

  if ! command -v streamdeck &> /dev/null; then
    echo "Installing streamdeck-gui-ng into venv..."
    mkdir -p "$VENV_DIR" "$HOME/.local/bin"
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install streamdeck-gui-ng
    ln -sf "$VENV_DIR/bin/streamdeck" "$HOME/.local/bin/streamdeck"
    ln -sf "$VENV_DIR/bin/streamdeckc" "$HOME/.local/bin/streamdeckc"
  else
    echo "streamdeck-gui-ng already installed."
  fi

else
  echo "[!] Unsupported operating system: $OS"
  exit 1
fi

# Choose config template based on OS
if [[ "$OS" == "Darwin" ]]; then
  CONFIG_SRC="$SCRIPT_DIR/streamdeck/configs/work-template.json"
else
  CONFIG_SRC="$SCRIPT_DIR/streamdeck/config.json"
fi
CONFIG_DEST="$HOME/.streamdeck_ui.json"

if [[ -f "$CONFIG_SRC" ]]; then
  if [[ -f "$CONFIG_DEST" && ! -L "$CONFIG_DEST" ]]; then
    echo "Backing up existing config to ${CONFIG_DEST}.bak"
    cp "$CONFIG_DEST" "${CONFIG_DEST}.bak"
  fi

  # Process template: resolve script paths placeholder
  SCRIPTS_PATH="$SCRIPT_DIR/streamdeck/scripts"
  sed "s|STREAMDECK_SCRIPTS/|${SCRIPTS_PATH}/|g" "$CONFIG_SRC" > "$CONFIG_DEST"

  # Try to detect Stream Deck serial number using the venv's Python
  SERIAL=""
  VENV_PYTHON="$VENV_DIR/bin/python"
  if [[ -x "$VENV_PYTHON" ]]; then
    SERIAL=$("$VENV_PYTHON" -c "
try:
    from StreamDeck.DeviceManager import DeviceManager
    decks = DeviceManager().enumerate()
    if decks:
        decks[0].open()
        print(decks[0].get_serial_number())
        decks[0].close()
except Exception:
    pass
" 2>/dev/null || true)
  fi

  if [[ -n "$SERIAL" ]]; then
    sed -i "s|YOUR_SERIAL_HERE|${SERIAL}|g" "$CONFIG_DEST"
    echo "Detected Stream Deck serial: $SERIAL"
  else
    echo "[!] No Stream Deck detected. Edit $CONFIG_DEST and replace YOUR_SERIAL_HERE with your device serial."
    echo "    Run: $VENV_PYTHON -c \"from StreamDeck.DeviceManager import DeviceManager; d=DeviceManager().enumerate(); d[0].open(); print(d[0].get_serial_number()); d[0].close()\""
  fi

  echo "Installed config: $CONFIG_SRC -> $CONFIG_DEST"
fi

# Make scripts executable
if [[ -d "$SCRIPT_DIR/streamdeck/scripts" ]]; then
  chmod +x "$SCRIPT_DIR/streamdeck/scripts/"*.sh
  echo "Made streamdeck scripts executable."
fi

# Install systemd user timer for status auto-refresh (Linux only)
if [[ "$OS" == "Linux" ]]; then
  SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
  mkdir -p "$SYSTEMD_USER_DIR"

  cat > "$SYSTEMD_USER_DIR/streamdeck-status.service" <<EOF
[Unit]
Description=Update Stream Deck status buttons
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_DIR/streamdeck/scripts/streamdeck-status-update.sh
TimeoutStartSec=30

[Install]
WantedBy=default.target
EOF

  cat > "$SYSTEMD_USER_DIR/streamdeck-status.timer" <<EOF
[Unit]
Description=Refresh Stream Deck status buttons every 30s

[Timer]
OnBootSec=10s
OnUnitActiveSec=30s
AccuracySec=5s

[Install]
WantedBy=timers.target
EOF

  systemctl --user daemon-reload
  systemctl --user enable --now streamdeck-status.timer
  echo "Enabled streamdeck-status.timer (refreshes every 30s)."
fi

echo "[✔] Stream Deck setup complete."
