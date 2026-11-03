#!/usr/bin/env bash
set -euo pipefail

PROJECT="$(terraform output -raw project_id)"
ZONE="$(terraform output -raw zone)"
CLUSTER="$(terraform output -raw gke_cluster_name)"

echo "==> Getting GKE credentials"

gcloud container clusters get-credentials "$CLUSTER" \
  --zone="$ZONE" \
  --project="$PROJECT"

echo
echo "===== FLEET ====="

gcloud container fleet memberships list \
  --project="$PROJECT"

echo
echo "===== WAITING FOR CONFIG SYNC ====="

READY=0

for i in $(seq 1 30); do
  echo "Attempt $i/30..."

  if kubectl get namespace gitops-demo >/dev/null 2>&1; then
    READY=1
    break
  fi

  sleep 10
done

if [ "$READY" -ne 1 ]; then
  echo
  echo "Config Sync did not reconcile within the expected time."
  echo
  echo "===== CONFIG MANAGEMENT STATUS ====="

  gcloud beta container fleet config-management status \
    --project="$PROJECT" || true

  echo
  echo "===== CONFIG SYNC PODS ====="

  kubectl get pods \
    --namespace=config-management-system || true

  exit 1
fi

echo
echo "===== CONFIG SYNC RESULT ====="

kubectl get namespace gitops-demo

kubectl get configmap fleet-demo-config \
  --namespace=gitops-demo \
  -o yaml

echo
echo "===== CONFIG SYNC COMPONENTS ====="

kubectl get pods \
  --namespace=config-management-system

echo
echo "===== POLICY CONTROLLER ====="

kubectl get pods \
  --namespace=gatekeeper-system
