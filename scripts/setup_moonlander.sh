#!/bin/bash

# setup_moonlander.sh - Installs QMK dependencies for Moonlander keyboard firmware

set -e

OS="$(uname -s)"

echo "[+] Installing QMK dependencies..."

if [[ "$OS" == "Linux" ]]; then
    # Only install missing apt packages
    MISSING=()
    for pkg in python3 python3-pip python3-venv pipx git gcc-arm-none-eabi dfu-util dos2unix; do
        dpkg -s "$pkg" &>/dev/null || MISSING+=("$pkg")
    done
    if [[ ${#MISSING[@]} -gt 0 ]]; then
        echo "Installing missing packages: ${MISSING[*]}"
        sudo apt update
        sudo apt install -y "${MISSING[@]}"
    else
        echo "All required apt packages already installed."
    fi

    # Install QMK CLI via pipx (pip install --user breaks on externally-managed Python)
    if ! command -v qmk &> /dev/null; then
        echo "Installing QMK CLI..."
        pipx ensurepath
        pipx install qmk
    else
        echo "QMK CLI already installed."
    fi

    # Install Keymapp (ZSA's official flashing tool, replaces deprecated wally-cli)
    if ! command -v keymapp &> /dev/null; then
        echo "Installing Keymapp..."
        KEYMAPP_URL="https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz"
        curl -fsSL "$KEYMAPP_URL" -o /tmp/keymapp.tar.gz
        tar -xzf /tmp/keymapp.tar.gz -C /tmp/
        chmod +x /tmp/keymapp
        sudo mv /tmp/keymapp /usr/local/bin/keymapp
        rm -f /tmp/keymapp.tar.gz
        echo "Keymapp installed."
    else
        echo "Keymapp already installed."
    fi

    # Add udev rules for flashing (use QMK's comprehensive rules file)
    QMK_RULES="$HOME/zsa_qmk_firmware/util/udev/50-qmk.rules"
    if [[ -f "$QMK_RULES" ]]; then
        echo "Installing QMK udev rules..."
        sudo cp "$QMK_RULES" /etc/udev/rules.d/50-qmk.rules
    else
        echo "[!] QMK udev rules not found at $QMK_RULES — run 'qmk setup' first, or continuing with ZSA rule only."
        sudo touch /etc/udev/rules.d/50-qmk.rules
    fi
    # Ensure ZSA Moonlander device IDs are covered
    # Normal mode (1972) — Keymapp needs access to detect the keyboard before reset
    if ! grep -q "3297.*1972" /etc/udev/rules.d/50-qmk.rules; then
        echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1972", MODE="0666", TAG+="uaccess"' \
            | sudo tee -a /etc/udev/rules.d/50-qmk.rules > /dev/null
    fi
    # Bootloader mode (2003) — needed for the actual flash
    if ! grep -q "3297.*2003" /etc/udev/rules.d/50-qmk.rules; then
        echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="2003", MODE="0666", TAG+="uaccess"' \
            | sudo tee -a /etc/udev/rules.d/50-qmk.rules > /dev/null
    fi
    sudo udevadm control --reload-rules && sudo udevadm trigger

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
