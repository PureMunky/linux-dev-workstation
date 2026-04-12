#!/bin/bash
# status-cpu.sh - Output CPU load and memory usage as compact text for Stream Deck
# When called with --detail, opens a terminal with htop

if [[ "$1" == "--detail" ]]; then
  wezterm start -- htop
  exit 0
fi

LOAD=$(awk '{printf "%.0f", $1}' /proc/loadavg)
CORES=$(nproc)
PCT=$(( LOAD * 100 / CORES ))

MEM_USED=$(free -g | awk '/Mem:/{print $3}')
MEM_TOTAL=$(free -g | awk '/Mem:/{print $7}')

echo "CPU ${PCT}%"
echo "Mem ${MEM_USED}/${MEM_TOTAL}G"
