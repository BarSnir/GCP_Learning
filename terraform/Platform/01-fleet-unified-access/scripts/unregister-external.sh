#!/usr/bin/env bash
set -euo pipefail

PROJECT="$1"
REGION="$2"
ZONE="$3"
VM="$4"
MEMBERSHIP="$5"
RUNTIME_DIR="$6"

mkdir -p "$RUNTIME_DIR"

K3S_CONFIG="$RUNTIME_DIR/k3s-fleet.yaml"

if ! gcloud container fleet memberships describe "$MEMBERSHIP" \
  --project="$PROJECT" \
  --location="$REGION" \
  >/dev/null 2>&1; then

  echo "==> External Fleet membership already removed"
  exit 0
fi

echo "==> Retrieving K3s configuration"

gcloud compute ssh "$VM" \
  --zone="$ZONE" \
  --project="$PROJECT" \
  --tunnel-through-iap \
  --quiet \
  --command="
    sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k3s-fleet.yaml
    sudo chmod 644 /tmp/k3s-fleet.yaml
  "

gcloud compute scp \
  "$VM:/tmp/k3s-fleet.yaml" \
  "$K3S_CONFIG" \
  --zone="$ZONE" \
  --project="$PROJECT" \
  --tunnel-through-iap \
  --quiet

CONTEXT="$(kubectl --kubeconfig="$K3S_CONFIG" config current-context)"

kubectl \
  --kubeconfig="$K3S_CONFIG" \
  config set-cluster default \
  --server=https://127.0.0.1:16443

echo "==> Opening temporary IAP tunnel"

gcloud compute start-iap-tunnel "$VM" 6443 \
  --local-host-port=127.0.0.1:16443 \
  --zone="$ZONE" \
  --project="$PROJECT" \
  >"$RUNTIME_DIR/iap-destroy.log" 2>&1 &

TUNNEL_PID=$!

cleanup() {
  kill "$TUNNEL_PID" 2>/dev/null || true
}

trap cleanup EXIT

for i in $(seq 1 30); do
  if kubectl --kubeconfig="$K3S_CONFIG" get nodes >/dev/null 2>&1; then
    break
  fi

  if [ "$i" -eq 30 ]; then
    cat "$RUNTIME_DIR/iap-destroy.log"
    exit 1
  fi

  sleep 2
done

echo "==> Unregistering external Kubernetes cluster"

gcloud container fleet memberships unregister "$MEMBERSHIP" \
  --project="$PROJECT" \
  --location="$REGION" \
  --context="$CONTEXT" \
  --kubeconfig="$K3S_CONFIG" \
  --quiet

echo "==> External cluster unregistered"
