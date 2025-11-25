# Automatic System Updates

This workstation setup includes automatic system updates to keep your machine secure without manual intervention.

## What Gets Configured

### Ubuntu/Debian (Linux)
- **unattended-upgrades** package installed and enabled
- **Security updates** installed automatically daily
- **Automatic reboots** at 3:00 AM when kernel updates require it
- **Cleanup** of unused packages and old kernels every 7 days
- **System timers** enabled for regular update checks

### macOS
- **Automatic update checks** enabled
- **Automatic downloads** of available updates
- **Security updates** installed automatically
- **App Store apps** update automatically

## Monitoring Updates

### Linux
Check the status and logs:
```bash
# View recent update activity
sudo tail -f /var/log/unattended-upgrades/unattended-upgrades.log

# Check if reboot is required
ls /var/run/reboot-required

# Check pending updates
apt list --upgradable

# Test configuration (dry run)
sudo unattended-upgrade --dry-run --debug

# Check timer status
systemctl status apt-daily.timer
systemctl status apt-daily-upgrade.timer
```

### macOS
Check update status:
```bash
# Check for updates
softwareupdate --list

# View update history
softwareupdate --history

# Check automatic update settings
defaults read /Library/Preferences/com.apple.SoftwareUpdate
```

## Configuration Files (Linux)

- `/etc/apt/apt.conf.d/20auto-upgrades` - Update frequency settings
- `/etc/apt/apt.conf.d/50unattended-upgrades` - Main configuration
- `/var/log/unattended-upgrades/` - Log directory

## Customization

### Change Reboot Time (Linux)
Edit `/etc/apt/apt.conf.d/50unattended-upgrades`:
```
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
```

### Disable Automatic Reboots (Linux)
Edit `/etc/apt/apt.conf.d/50unattended-upgrades`:
```
Unattended-Upgrade::Automatic-Reboot "false";
```

### Enable All Updates (not just security) (Linux)
Edit `/etc/apt/apt.conf.d/50unattended-upgrades` and uncomment:
```
"${distro_id}:${distro_codename}-updates";
```

### Disable Automatic Updates

**Linux:**
```bash
sudo dpkg-reconfigure unattended-upgrades
# Select "No" when prompted
```

**macOS:**
```bash
sudo softwareupdate --schedule off
```

## Re-running Setup

If you need to re-configure automatic updates:
```bash
./scripts/setup_auto_updates.sh
```

## Security Considerations

- **Security-only updates** (default) are generally safe and highly recommended
- **Automatic reboots** ensure kernel security patches are applied promptly
- **Logs** are kept in case you need to troubleshoot any issues
- **Minimal disruption** - updates happen in the background, reboots at 3 AM

## Troubleshooting

### Updates aren't running (Linux)
```bash
# Check if service is enabled
systemctl list-timers | grep apt

# Manually trigger an update check
sudo unattended-upgrade --debug

# Check for errors in logs
sudo tail -100 /var/log/unattended-upgrades/unattended-upgrades.log
```

### Disable temporarily (Linux)
```bash
sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer
```

### Re-enable (Linux)
```bash
sudo systemctl start apt-daily.timer apt-daily-upgrade.timer
```
