#!/bin/bash
# status-network.sh - Output network status for Stream Deck
# When called with --detail, opens terminal with network info

if [[ "$1" == "--detail" ]]; then
  wezterm start -- bash -c 'echo "=== Interfaces ==="; ip -br addr show; echo; echo "=== Routes ==="; ip route; echo; echo "=== DNS ==="; resolvectl status 2>/dev/null || cat /etc/resolv.conf; echo; read -p "Press enter to close..."'
  exit 0
fi

# Get primary non-loopback, non-docker IP
IP=$(ip -4 -br addr show | grep -vE 'lo|docker|br-|veth' | grep UP | awk '{print $3}' | cut -d/ -f1 | head -1)

if [[ -z "$IP" ]]; then
  echo "Net"
  echo "DOWN"
  exit 0
fi

# Get interface name for wifi SSID
IFACE=$(ip -4 -br addr show | grep -vE 'lo|docker|br-|veth' | grep UP | awk '{print $1}' | head -1)
SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
if [[ -z "$SSID" ]] && command -v iwgetid &>/dev/null; then
  SSID=$(iwgetid -r 2>/dev/null)
fi

if [[ -n "$SSID" ]]; then
  echo "$SSID"
else
  echo "Net"
fi
echo "$IP"
