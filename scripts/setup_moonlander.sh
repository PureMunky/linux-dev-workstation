#!/bin/bash

# setup_moonlander.sh - Installs QMK dependencies for Moonlander keyboard firmware

set -e

OS="$(uname -s)"

echo "[+] Installing QMK dependencies..."

if [[ "$OS" == "Linux" ]]; then
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv pipx git

    # Install QMK CLI via pipx (pip install --user breaks on externally-managed Python)
    if ! command -v qmk &> /dev/null; then
        echo "Installing QMK CLI..."
        pipx ensurepath
        pipx install qmk
    else
        echo "QMK CLI already installed."
    fi

    # Add udev rules for Moonlander flashing
    if [[ ! -f /etc/udev/rules.d/50-zsa.rules ]]; then
        echo "Adding ZSA udev rules for flashing..."
        sudo tee /etc/udev/rules.d/50-zsa.rules > /dev/null << 'RULES'
# ZSA Moonlander
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", TAG+="uaccess"
# STM32 DFU bootloader (for flashing)
SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", TAG+="uaccess"
RULES
        sudo udevadm control --reload-rules && sudo udevadm trigger
    fi

elif [[ "$OS" == "Darwin" ]]; then
    brew install python3 git pipx
    pipx ensurepath

    if ! command -v qmk &> /dev/null; then
        echo "Installing QMK CLI..."
        pipx install qmk
    else
        echo "QMK CLI already installed."
    fi

else
    echo "[!] Unsupported operating system: $OS"
    exit 1
fi

echo "[✔] QMK dependencies installed."
