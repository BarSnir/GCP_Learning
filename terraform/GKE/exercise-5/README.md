# GKE Exercise 5 — IAM & Workload Identity Federation

## Goal

Allow a GKE workload to access a Google Cloud resource without storing a service-account key.

Topics:

- GKE Node Service Account
- Kubernetes ServiceAccount
- Workload Identity Federation for GKE
- IAM principals
- Least privilege
- Direct resource access
- Cloud Storage IAM

## Architecture

```text
Pod
 |
 | serviceAccountName: gcs-reader
 v
Kubernetes ServiceAccount
 |
 | Workload Identity Federation
 v
GCP IAM Principal
 |
 | roles/storage.objectViewer
 v
Cloud Storage Bucket
```

## Identity Separation

```text
Node Service Account
→ identity used by the GKE worker VM

Kubernetes ServiceAccount
→ Kubernetes identity used by a Pod

Workload Identity Federation
→ maps the Kubernetes workload identity into Google Cloud IAM
```

The Pod does not need:

- A downloaded JSON key
- A Kubernetes Secret containing Google credentials
- The permissions of the Node Service Account

## Security Principle

Grant IAM permissions to the workload that actually requires them.

```text
Wrong:
Node has broad permissions
      ↓
Every workload potentially inherits too much access

Preferred:
Specific Kubernetes ServiceAccount
      ↓
Specific IAM role
      ↓
Specific Google Cloud resource
```

## Cost Strategy

- One zonal GKE Standard cluster
- One e2-small Node
- One small Cloud Storage object
- No Load Balancer
- Logging and Monitoring disabled

---

# Results

## Workload Identity Federation

The GKE cluster was configured with:

```text
pca-certifciation.svc.id.goog
```

Pods use the GKE metadata server to obtain short-lived Google Cloud credentials.

No service-account JSON key was created or mounted.

---

## Identity Test

Two Pods ran in the same namespace and cluster.

### Pod without permission

```text
Pod: no-access
Kubernetes ServiceAccount: default
```

Attempting to read:

```text
gs://<bucket>/hello.txt
```

returned:

```text
HTTP 403
storage.objects.get denied
```

### Pod with permission

```text
Pod: with-access
Kubernetes ServiceAccount: gcs-reader
```

The IAM principal representing this Kubernetes ServiceAccount received:

```text
roles/storage.objectViewer
```

The same Cloud Storage read succeeded.

---

# Identity Model

```text
GKE Node
|
+-- Pod A
|    |
|    +-- KSA: default
|         |
|         +-- no Storage IAM
|              |
|              +-- 403
|
+-- Pod B
     |
     +-- KSA: gcs-reader
          |
          +-- Workload Identity Federation
               |
               +-- roles/storage.objectViewer
                    |
                    +-- Cloud Storage ✅
```

The Pods may run on the same worker Node but still receive different Google Cloud permissions.

---

# Node Identity vs Workload Identity

## Node Service Account

Used by the worker VM for GKE node-level operations.

```text
GKE Node
↓
gke-ex5-node-sa
```

Application workloads should not depend on broad permissions granted to this identity.

## Kubernetes ServiceAccount

Used to identify a Kubernetes workload.

```text
Pod
↓
serviceAccountName: gcs-reader
```

## Workload Identity Federation

Connects the Kubernetes workload identity to Google Cloud IAM.

```text
Kubernetes ServiceAccount
        ↓
Workload Identity Pool
        ↓
Google Cloud IAM Principal
```

---

# Security Takeaways

## Avoid Service Account Keys

We did not use:

```text
JSON key files
Kubernetes Secrets containing Google credentials
Hard-coded credentials
```

Instead, credentials are short-lived and obtained dynamically through Workload Identity Federation.

## Least Privilege

The workload received only:

```text
roles/storage.objectViewer
```

and only on the specific bucket used by the exercise.

The default Kubernetes ServiceAccount received no Cloud Storage permission.

---

# Architecture Takeaway

```text
Kubernetes identity
        +
Workload Identity Federation
        +
Google Cloud IAM
        =
Per-workload Google Cloud authorization
```

Permissions should follow the workload that needs them rather than the Node on which the workload happens to run.

---

# Cost Strategy

- One zonal GKE Standard cluster
- One e2-small worker
- One small Cloud Storage bucket/object
- No Load Balancer
- Cloud Logging and Monitoring disabled
- All exercise resources destroyed after completion
