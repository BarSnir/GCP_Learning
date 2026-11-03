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

for i in $(seq 1 30); do
  if kubectl get namespace gitops-demo >/dev/null 2>&1; then
    break
  fi

  sleep 10
done

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
