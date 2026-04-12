#!/bin/bash
# status-disk.sh - Output disk usage for Stream Deck
# When called with --detail, opens terminal with disk breakdown

if [[ "$1" == "--detail" ]]; then
  wezterm start -- bash -c 'df -h; echo; echo "=== Large dirs ==="; du -h --max-depth=1 ~ 2>/dev/null | sort -rh | head -15; echo; read -p "Press enter to close..."'
  exit 0
fi

USAGE=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
USED=$(df -h / | awk 'NR==2{print $3}')
AVAIL=$(df -h / | awk 'NR==2{print $4}')

echo "Disk ${USAGE}%"
echo "${USED}/${AVAIL}"
