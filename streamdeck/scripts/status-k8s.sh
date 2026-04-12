#!/bin/bash
# status-k8s.sh - Output Kubernetes pod status for Stream Deck
# When called with --detail, opens k9s

if [[ "$1" == "--detail" ]]; then
  wezterm start -- k9s
  exit 0
fi

CTX=$(kubectl config current-context 2>/dev/null)
if [[ -z "$CTX" ]]; then
  echo "K8s"
  echo "no ctx"
  exit 0
fi

# Short context name: strip common prefixes, keep it readable
SHORT_CTX=$(echo "$CTX" | sed -e 's/.*\///' -e 's/^kind-/k:/' | cut -c1-12)

PODS=$(kubectl get pods -A --no-headers 2>/dev/null)
if [[ -z "$PODS" ]]; then
  echo "$SHORT_CTX"
  echo "no pods"
  exit 0
fi

RUNNING=$(echo "$PODS" | grep -c "Running")
NOT_READY=$(echo "$PODS" | grep -vcE "Running|Completed")

if [[ "$NOT_READY" -gt 0 ]]; then
  echo "$SHORT_CTX"
  echo "${RUNNING}ok ${NOT_READY}bad"
else
  echo "$SHORT_CTX"
  echo "${RUNNING} pods"
fi
