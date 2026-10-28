#!/usr/bin/env bash
set -euo pipefail

PROJECT="$1"
REGION="$2"
ZONE="$3"
VM="$4"
MEMBERSHIP="$5"
GKE_MEMBERSHIP="$6"
GATEWAY_USER="$7"
RUNTIME_DIR="$8"

mkdir -p "$RUNTIME_DIR"

K3S_CONFIG="$RUNTIME_DIR/k3s-fleet.yaml"
EXTERNAL_GATEWAY="$RUNTIME_DIR/external-gateway.yaml"
GKE_GATEWAY="$RUNTIME_DIR/gke-gateway.yaml"

echo "==> Waiting for K3s configuration"

gcloud compute ssh "$VM" \
  --zone="$ZONE" \
  --project="$PROJECT" \
  --tunnel-through-iap \
  --quiet \
  --command="
    until sudo test -f /etc/rancher/k3s/k3s.yaml; do
      sleep 5
    done

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

CONTEXT="$(kubectl --kubeconfig="$K3S_CONFIG" config current-context 2>/dev/null || true)"

if [ -z "$CONTEXT" ]; then
  CONTEXT="$(kubectl --kubeconfig="$K3S_CONFIG" config get-contexts -o name | head -n 1)"
  kubectl --kubeconfig="$K3S_CONFIG" config use-context "$CONTEXT"
fi

kubectl \
  --kubeconfig="$K3S_CONFIG" \
  config set-cluster default \
  --server=https://127.0.0.1:16443

echo "==> Opening temporary IAP tunnel"

gcloud compute start-iap-tunnel "$VM" 6443 \
  --local-host-port=127.0.0.1:16443 \
  --zone="$ZONE" \
  --project="$PROJECT" \
  >"$RUNTIME_DIR/iap.log" 2>&1 &

TUNNEL_PID=$!

cleanup() {
  kill "$TUNNEL_PID" 2>/dev/null || true
}

trap cleanup EXIT

echo "==> Waiting for Kubernetes API"

for i in $(seq 1 30); do
  if kubectl --kubeconfig="$K3S_CONFIG" get nodes >/dev/null 2>&1; then
    break
  fi

  if [ "$i" -eq 30 ]; then
    cat "$RUNTIME_DIR/iap.log"
    exit 1
  fi

  sleep 2
done

echo "==> Registering external Kubernetes cluster with Fleet"

if ! gcloud container fleet memberships describe "$MEMBERSHIP" \
  --project="$PROJECT" \
  --location="$REGION" \
  >/dev/null 2>&1; then

  gcloud container fleet memberships register "$MEMBERSHIP" \
    --project="$PROJECT" \
    --location="$REGION" \
    --context="$CONTEXT" \
    --kubeconfig="$K3S_CONFIG" \
    --enable-workload-identity \
    --has-private-issuer \
    --quiet
fi

echo "==> Configuring Connect Gateway RBAC"

gcloud container fleet memberships generate-gateway-rbac \
  --membership="$MEMBERSHIP" \
  --role=clusterrole/cluster-admin \
  --users="$GATEWAY_USER" \
  --project="$PROJECT" \
  --kubeconfig="$K3S_CONFIG" \
  --context="$CONTEXT" \
  --apply

echo "==> Creating external Connect Gateway kubeconfig"

rm -f "$EXTERNAL_GATEWAY"

KUBECONFIG="$EXTERNAL_GATEWAY" \
gcloud container fleet memberships get-credentials "$MEMBERSHIP" \
  --project="$PROJECT" \
  --location="$REGION"

echo "==> Creating GKE Connect Gateway kubeconfig"

rm -f "$GKE_GATEWAY"

KUBECONFIG="$GKE_GATEWAY" \
gcloud container fleet memberships get-credentials "$GKE_MEMBERSHIP" \
  --project="$PROJECT" \
  --location="$REGION"

echo "==> Fleet registration complete"
