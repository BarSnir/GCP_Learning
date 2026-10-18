# GKE Exercise 4 — Node Pools & Autoscaling

## Goal

Understand how GKE separates workload placement from workload scaling.

Topics:

- Multiple Node Pools
- Node labels
- Node taints and Pod tolerations
- Node selectors
- Cluster Autoscaler
- Horizontal Pod Autoscaler (HPA)
- Vertical Pod Autoscaler (VPA)

## Architecture

```text
GKE Cluster
|
+-- system-pool
|     |
|     +-- 1 x e2-small
|     +-- label: pool=system
|
+-- app-pool
      |
      +-- autoscaling: 0-2 nodes
      +-- label: pool=apps
      +-- taint: dedicated=apps:NoSchedule
```

## Scaling Layers

```text
HPA
|
| changes Pod replica count
v
Pods
|
| Pods cannot be scheduled?
v
Cluster Autoscaler
|
| changes Node count
v
Node Pool
```

VPA operates on a different dimension:

```text
VPA
|
| changes / recommends
v
CPU & memory requests per Pod
```

## Cost Strategy

- One always-on e2-small system node
- Application pool starts at zero
- Application pool scales only when needed
- Maximum two application nodes
- Logging and Monitoring disabled for this lab
- Extra Nodes will exist only during autoscaling tests

---

# Results

## Node Pools

The cluster used two logical node pools:

```text
system-pool
└── 1 x e2-small

app-pool
└── autoscaling 0-2 nodes
