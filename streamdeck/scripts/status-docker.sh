#!/bin/bash
# status-docker.sh - Output Docker container counts for Stream Deck
# When called with --detail, opens a terminal with docker ps

if [[ "$1" == "--detail" ]]; then
  wezterm start -- bash -c 'docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; echo; read -p "Press enter to close..."'
  exit 0
fi

if ! docker info &>/dev/null; then
  echo "Docker"
  echo "DOWN"
  exit 0
fi

RUNNING=$(docker ps -q 2>/dev/null | wc -l)
STOPPED=$(docker ps -aq --filter "status=exited" 2>/dev/null | wc -l)

echo "Docker"
if [[ "$STOPPED" -gt 0 ]]; then
  echo "${RUNNING}up ${STOPPED}off"
else
  echo "${RUNNING} running"
fi
