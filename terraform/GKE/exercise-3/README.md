# GKE Exercise 3 — Kubernetes Workload Controllers

## Goal

Understand and compare the main Kubernetes workload resources:

- Pod
- ReplicaSet
- Deployment
- StatefulSet
- DaemonSet

## Cluster

GKE Standard zonal cluster with a small, cost-efficient node pool.

```text
GKE Control Plane
       |
       v
Node Pool
       |
       +--> Pod
       +--> ReplicaSet
       +--> Deployment
       +--> StatefulSet
       +--> DaemonSet
```

## Cost Strategy

The exercise starts with one `e2-small` node.

A second node will be added only temporarily when testing DaemonSet behavior and removed immediately afterward.

Cloud Logging and Cloud Monitoring are disabled for this lab.

---

## Workload Controllers

### Pod

A standalone Pod has no controller.

```text
Pod deleted
    ↓
Gone permanently
```

### ReplicaSet

Maintains a desired number of identical Pods.

```text
ReplicaSet
    |
    ├── Pod
    └── Pod

One Pod dies
    ↓
ReplicaSet creates another
```

### Deployment

Manages ReplicaSets and provides rollout and revision management.

```text
Deployment
    |
    ├── ReplicaSet v1 → 0 Pods
    |
    └── ReplicaSet v2 → 2 Pods
```

Key capabilities:

- Rolling updates
- Rollout status
- Revision history
- Rollback
- Replica management

### StatefulSet

Provides stable workload identity.

```text
nginx-stateful-0
nginx-stateful-1
```

A recreated Pod keeps the same ordinal identity even if its IP changes.

With persistent storage, each identity can also retain its own volume.

Typical use cases:

- Databases
- Kafka
- Distributed stateful systems

### DaemonSet

Maintains one Pod on every eligible Node.

```text
Node A → Agent Pod
Node B → Agent Pod
Node C → Agent Pod
```

When a Node joins, the DaemonSet automatically creates a Pod on it.

Typical use cases:

- Log collectors
- Monitoring agents
- Security agents
- Networking agents

---

## Controller Hierarchy

```text
Deployment
    ↓
ReplicaSet
    ↓
Pod
```

A Deployment normally manages ReplicaSets rather than Pods directly.

---

## Architecture Takeaways

### Desired State

Kubernetes controllers continuously reconcile:

```text
Desired State
     ↕
Actual State
```

If they differ, Kubernetes attempts to make the actual state match the desired state.

### Stateless vs Stateful

```text
Deployment
→ Pods are interchangeable

StatefulSet
→ Pods have stable identities
```

### Replica Count vs Node Count

```text
Deployment
→ number of Pods is defined by replicas

DaemonSet
→ number of Pods follows eligible Nodes
```

---

## Cost Strategy

The cluster normally used one `e2-small` Node.

A second Node was created only temporarily to demonstrate DaemonSet behavior and was removed immediately afterward.
