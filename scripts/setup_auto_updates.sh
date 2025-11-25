#!/bin/bash

# setup_auto_updates.sh - Configure automatic system updates

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

if [[ "$OS" == "Linux" ]]; then
  echo "[+] Configuring automatic updates for Ubuntu/Debian..."

  # Install unattended-upgrades
  sudo apt update
  sudo apt install -y unattended-upgrades apt-listchanges

  # Enable unattended-upgrades
  echo "[+] Enabling unattended-upgrades..."
  sudo dpkg-reconfigure -plow unattended-upgrades

  # Configure periodic updates
  sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

  # Configure unattended-upgrades settings
  CONFIG_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"

  # Enable security updates (default)
  echo "[+] Configuring security updates..."

  # Optionally enable automatic reboot at 3 AM if required
  sudo sed -i 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|' "$CONFIG_FILE"
  sudo sed -i 's|//Unattended-Upgrade::Automatic-Reboot-Time "02:00";|Unattended-Upgrade::Automatic-Reboot-Time "03:00";|' "$CONFIG_FILE"

  # Remove unused kernel packages automatically
  sudo sed -i 's|//Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";|Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";|' "$CONFIG_FILE"
  sudo sed -i 's|//Unattended-Upgrade::Remove-Unused-Dependencies "false";|Unattended-Upgrade::Remove-Unused-Dependencies "true";|' "$CONFIG_FILE"

  # Enable the systemd timers
  sudo systemctl enable apt-daily.timer
  sudo systemctl enable apt-daily-upgrade.timer
  sudo systemctl start apt-daily.timer
  sudo systemctl start apt-daily-upgrade.timer

  echo "[✔] Automatic updates configured for Ubuntu."
  echo "    - Security updates will be installed automatically"
  echo "    - System will auto-reboot at 3 AM if required"
  echo "    - Logs: /var/log/unattended-upgrades/"

elif [[ "$OS" == "Darwin" ]]; then
  echo "[+] Configuring automatic updates for macOS..."

  # Enable automatic software updates
  sudo softwareupdate --schedule on

  # Configure automatic update checks
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true

  # Enable automatic security updates
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

  # Enable automatic app updates from App Store
  sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true

  echo "[✔] Automatic updates configured for macOS."
  echo "    - System updates will be downloaded automatically"
  echo "    - Security updates will be installed automatically"
  echo "    - App Store apps will update automatically"

else
  echo "[!] Unsupported operating system: $OS"
  exit 1
fi
