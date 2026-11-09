#!/usr/bin/env bash
set -euo pipefail

PROJECT="pca-certifciation"
NETWORK="mesh-traffic-network"

echo "Searching for Cloud Service Mesh managed firewall rules..."

RULES=$(gcloud compute firewall-rules list \
  --project="$PROJECT" \
  --filter="network:$NETWORK AND name~'^gke-csm-thc-'" \
  --format="value(name)")

if [ -z "$RULES" ]; then
  echo "No gke-csm-thc firewall rules found."
else
  for rule in $RULES; do
    echo "Deleting $rule"
    gcloud compute firewall-rules delete "$rule" \
      --project="$PROJECT" \
      --quiet
  done
fi

echo "Pre-destroy cleanup complete."
