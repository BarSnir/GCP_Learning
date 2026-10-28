# Exercise 1 - Fleet + External Kubernetes + Unified Access

## Goal

Create the foundation for a heterogeneous Kubernetes Fleet.

The environment contains:

- One GKE Standard cluster
- One external Kubernetes cluster running K3s on a Compute Engine VM
- GKE Fleet membership
- Infrastructure required for Connect Agent and Connect Gateway

## Architecture

Fleet Host Project

├── GKE Cluster
│   └── Fleet Membership
│
└── External Kubernetes
    └── K3s on Compute Engine
        └── Will be attached to the Fleet in the next part

## Learning Objectives

- Understand Fleet Host Projects
- Understand Fleet Membership
- Register a GKE cluster with a Fleet
- Run a non-GKE Kubernetes cluster
- Attach an external Kubernetes cluster
- Understand Connect Agent
- Use Connect Gateway for unified access

## Terraform

Terraform files:

- main.tf
- inputs.tf
- outputs.tf

Infrastructure is managed almost entirely through Terraform.

---

# Exercise 1 - Final Summary

## What We Built

- GKE Standard cluster
- External Kubernetes cluster using K3s on Compute Engine
- Google Cloud Fleet
- GKE Fleet Membership
- External Kubernetes Fleet Membership
- Connect Agent on the external cluster
- Connect Gateway access to both clusters

Architecture:

Fleet
├── GKE
└── External K3s
    └── Connect Agent

Both clusters can be accessed centrally through Connect Gateway.

## Important Concepts

- Fleet is the central management layer.
- GKE and external Kubernetes remain separate clusters.
- Fleet does not merge their Kubernetes API servers.
- kubectl always targets one cluster at a time.
- Connect Agent is required for the external Kubernetes cluster.
- Connect Gateway provides centralized access using Google identity.

## Errors and Fixes

### Fleet Membership creation failed

Error:

cluster is currently running another operation

Cause:

Terraform attempted to create the Fleet Membership while the GKE Node Pool was still being created.

Fix:

Added an explicit dependency:

google_container_node_pool.fleet
→ google_gke_hub_membership.gke

### IAP tunnel to K3s failed

Cause:

The firewall allowed IAP only on TCP/22.

Fix:

Added TCP/6443 to the IAP firewall rule.

### K3s kubeconfig issue

The original kubeconfig retrieval did not provide a usable local context.

Fix:

Copied /etc/rancher/k3s/k3s.yaml from the VM using gcloud compute scp.

### Connect Gateway returned 403

Verbose debugging:

kubectl --kubeconfig=./external-gateway.yaml get nodes -v=9

showed that:

system:serviceaccount:gke-connect:connect-agent-sa

could not impersonate the Google user.

Fix:

Generated Gateway RBAC for the exact Google identity and applied it to K3s.

## Key Lessons Learned

1. Fleet can manage GKE and non-GKE Kubernetes clusters together.
2. A Fleet Membership represents a cluster inside the Fleet.
3. External Kubernetes uses the Connect Agent.
4. Connect Agent establishes an outbound connection to Google Cloud.
5. Connect Gateway provides unified access but does not merge clusters.
6. Google IAM and Kubernetes RBAC are separate authorization layers.
7. Connect Agent must be able to impersonate the Google user.
8. Kubernetes usernames must match exactly.
9. kubectl -v=9 is useful for troubleshooting Connect Gateway.
10. Terraform dependencies are important when multiple operations modify the same GKE cluster.

## Final State

Fleet
├── fleet-gke-membership
│   └── GKE
│
└── external-k8s-membership
    └── K3s
        └── Connect Agent

Infrastructure is intentionally kept running for Exercise 2.

