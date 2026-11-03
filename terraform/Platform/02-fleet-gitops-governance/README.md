

---

# Exercise 2 - Fleet GitOps & Governance

## What We Built

- GKE cluster registered to a Fleet
- Config Sync connected to the GitHub repository
- Git repository used as the Kubernetes source of truth
- Policy Controller / Gatekeeper enabled
- Required-label policy enforced on Kubernetes Deployments

## Config Sync Flow

GitHub
  ↓
RootSync
  ↓
root-reconciler
  ↓
GKE

The synchronized repository path was:

terraform/Platform/02-fleet-gitops-governance/config-sync

## GitOps Validation

The ConfigMap version was changed in Git from:

v1

to:

v2

After pushing the commit, Config Sync automatically updated the Kubernetes
ConfigMap without using kubectl apply.

This demonstrated:

Git = Desired State

## Drift Correction

A Kubernetes resource managed by Config Sync can be changed manually,
creating configuration drift.

Config Sync continuously reconciles the cluster back to the desired state
defined in Git.

## Policy Controller

Policy Controller installed the Gatekeeper template library.

The K8sRequiredLabels ConstraintTemplate was used to create:

deployments-must-have-owner

The policy requires every Deployment to contain:

owner=<value>

A Deployment without the label was rejected:

admission webhook validation.gatekeeper.sh denied the request:
Every Deployment must have an owner label.

A Deployment containing the owner label was successfully created.

## Architecture

Fleet
└── GKE Membership
    ├── Config Sync
    │   └── GitHub source of truth
    │
    └── Policy Controller
        └── Gatekeeper admission policies

## Errors and Fixes

### Config Sync management field rejected

The original Terraform configuration used:

management = "MANAGEMENT_AUTOMATIC"

The API returned an error because Config Sync auto-upgrades through this
field are no longer supported.

Fix:

Removed the management field.

### Fleet Default did not install Config Sync

The Fleet Default configuration existed, but the membership showed:

CONFIG_SYNC_PENDING
NOT_INSTALLED

and no Config Sync pods existed.

Fix:

Config Sync and Policy Controller were configured explicitly using
google_gke_hub_feature_membership for the Fleet membership.

### GKE node had insufficient memory

The original node type was:

e2-small

Policy Controller pods failed scheduling with:

Insufficient memory

Config Sync installation also failed while cluster resources were constrained.

Fix:

Changed the node to:

e2-standard-2

After the node replacement:

- Gatekeeper pods became Running
- reconciler-manager became Running
- root-reconciler became Running
- Config Sync became Healthy
- Git resources were successfully reconciled

### Config Sync initially reported InternalError

During installation ConfigSync showed temporary errors such as:

object has been modified
not all objects applied

After increasing node capacity and allowing reconciliation to complete,
ConfigSync reported:

Ready: True
Healthy: true
Phase: Current

## Lessons Learned

1. Fleet features can be configured for individual Fleet memberships.
2. Config Sync turns Git into the Kubernetes desired-state source.
3. Kubernetes resources can be created without kubectl apply.
4. Config Sync automatically corrects configuration drift.
5. RootSync represents synchronization of the root Git repository.
6. root-reconciler performs reconciliation from Git into Kubernetes.
7. Policy Controller uses Gatekeeper for Kubernetes admission control.
8. ConstraintTemplates define reusable policy logic.
9. Constraints configure and activate those templates.
10. A ConstraintTemplate alone does not enforce anything.
11. Admission policies can deny invalid Kubernetes resources before creation.
12. GKE system components, Config Sync, and Policy Controller require enough node memory.
13. e2-small was insufficient for this lab; e2-standard-2 was suitable.
14. Config Sync status and Kubernetes pod status should both be checked when troubleshooting.
15. Git operations on this work computer are performed through the alpine_container Docker container.

## Final Result

Config Sync:
Git -> GKE = Working

Policy Controller:
Invalid Deployment -> Denied
Valid Deployment -> Allowed

Exercise 2 completed successfully.

