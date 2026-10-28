#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="$(cd "$(dirname "$0")/.." && pwd)/.runtime"

echo "===== GKE THROUGH CONNECT GATEWAY ====="

kubectl \
  --kubeconfig="$RUNTIME_DIR/gke-gateway.yaml" \
  get nodes -o wide

echo
echo "===== EXTERNAL K3S THROUGH CONNECT GATEWAY ====="

kubectl \
  --kubeconfig="$RUNTIME_DIR/external-gateway.yaml" \
  get nodes -o wide

echo
echo "===== FLEET MEMBERSHIPS ====="

gcloud container fleet memberships list
