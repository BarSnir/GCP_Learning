# GKE Exercise 7 — Dynamic Volumes & PodDisruptionBudget

## Goal

Understand two important GKE concepts:

- Dynamic persistent storage
- Controlled Pod disruption

---

## 1. Compute Engine PD CSI Driver

The cluster explicitly enabled:

```text
gcePersistentDiskCsiDriver
```

The relevant StorageClass was:

```text
standard-rwo
```

with:

```text
provisioner: pd.csi.storage.gke.io
type: pd-balanced
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

---

## 2. Dynamic Volume Provisioning

We created only a PersistentVolumeClaim:

```text
PVC: app-data
Size: 5Gi
StorageClass: standard-rwo
```

We did not manually create:

```text
PersistentVolume
Compute Engine Persistent Disk
```

The flow was:

```text
PVC
 |
 v
StorageClass
 |
 v
PD CSI Driver
 |
 v
PersistentVolume
 |
 v
Compute Engine Persistent Disk
```

Because the StorageClass used:

```text
WaitForFirstConsumer
```

the disk was not provisioned until a Pod actually requested the PVC.

This allows Kubernetes to choose the correct zone before provisioning the disk.

---

## 3. Persistent Data

The StatefulSet mounted the PVC at:

```text
/data
```

We wrote:

```text
Persistent data from GKE Exercise 7
```

to:

```text
/data/message.txt
```

Then we deleted the Pod.

The StatefulSet recreated:

```text
storage-demo-0
```

The Pod UID changed, proving it was a new Pod.

However:

```text
/data/message.txt
```

still contained the original data.

Architecture:

```text
Old Pod
   |
   X deleted

PVC
 |
 v
PersistentVolume
 |
 v
Compute Engine Persistent Disk
 |
 v
New Pod
 |
 v
Same Data
```

### Key lesson

Pod lifecycle and persistent storage lifecycle are separate.

Deleting a Pod does not automatically delete the data stored on its PersistentVolume.

---

## 4. PodDisruptionBudget

We created:

```text
replicas: 2
minAvailable: 1
```

This means Kubernetes may voluntarily disrupt at most one healthy Pod while still satisfying the budget.

Example:

```text
2 healthy Pods
      |
      | evict one
      v
1 available Pod
      |
      v
PDB blocks another voluntary eviction
```

---

## 5. PDB and Node Drain

A node drain uses Kubernetes eviction semantics.

Example:

```text
kubectl drain
```

The PDB can prevent the drain from evicting too many Pods at once.

After the test, the node must be made schedulable again with:

```text
kubectl uncordon
```

---

## PDB Does Protect Against

```text
kubectl drain
planned node maintenance
controlled Pod eviction
some cluster upgrades
```

## PDB Does Not Protect Against

```text
VM crash
hardware failure
application crash
kubectl delete pod
```

A PDB controls voluntary disruption.

It is not a replacement for replicas, multi-zone architecture, or application-level high availability.

---

## Example

With:

```text
replicas: 3
minAvailable: 2
```

the maximum number of Pods that may be voluntarily evicted at the same time is:

```text
1
```

because:

```text
3 - 1 = 2 available
```

---

# Storage Mental Model

```text
Pod
 |
 v
PVC
 |
 v
StorageClass
 |
 v
CSI Driver
 |
 v
PV
 |
 v
Cloud Persistent Disk
```

The application asks for storage through a PVC.

Kubernetes and the CSI driver handle the cloud-specific disk provisioning.

---

# Key Lessons Learned

### Dynamic Provisioning

Applications normally request storage through PVCs rather than directly creating cloud disks.

### StorageClass

A StorageClass defines how Kubernetes should provision storage.

### WaitForFirstConsumer

Provisioning can wait until Kubernetes knows where the consuming Pod will run.

### PersistentVolume

The PV represents the actual storage resource used by Kubernetes.

### Pod Independence

A Pod can disappear while its persistent data survives.

### PodDisruptionBudget

A PDB controls how many Pods may be unavailable during voluntary disruption.

### Availability

Persistent storage protects data.

PDB protects workload availability during planned disruption.

They solve different problems.

---

# Cost Strategy

This lab used:

```text
1 zonal GKE Standard cluster
1 e2-small node
1 small Persistent Disk
No Load Balancer
No observability stack
```

All resources are destroyed after the exercise.
