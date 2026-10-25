# GKE Exercise 8 — Services & Gateway API

## Goal

Understand how traffic reaches Kubernetes workloads and how GKE implements Layer 7 routing.

Covered:

- ClusterIP
- NodePort
- Gateway API
- GatewayClass
- Gateway
- HTTPRoute
- Path-based routing
- Ingress vs Gateway API
- Shared Gateway architecture

---

# 1. ClusterIP

A ClusterIP Service provides a stable internal virtual IP for a workload.

```text
Pod
 |
 v
ClusterIP Service
 |
 v
Backend Pods
```

It is reachable from inside the cluster.

Example:

```text
http://team-a
```

returned:

```html
<h1>Team A</h1>
```

---

# 2. NodePort

A NodePort Service still has a ClusterIP.

It adds an additional port on every Kubernetes node.

```text
Pod
 |
 v
ClusterIP
 |
 v
NodeIP:NodePort
```

The exercise verified access using:

```text
Node Internal IP + NodePort
```

No public firewall rule was added.

---

# 3. Gateway API

Gateway API was enabled directly on the GKE cluster.

GKE created managed GatewayClasses including:

```text
gke-l7-global-external-managed
gke-l7-regional-external-managed
gke-l7-gxlb
gke-l7-rilb
```

The exercise used:

```text
gke-l7-global-external-managed
```

---

# 4. Gateway

A Gateway named:

```text
shared-gateway
```

created a Google Cloud external Layer 7 Load Balancer.

The Gateway eventually reached:

```text
PROGRAMMED=True
```

and received a public IP.

Important lesson:

```text
PROGRAMMED=True
```

does not necessarily mean the application is immediately reachable.

The Google Cloud Load Balancer backends can still require time for health checks and propagation.

---

# 5. HTTPRoute

One HTTPRoute configured two paths:

```text
/team-a
/team-b
```

Routing:

```text
Internet
   |
   v
Google Cloud Load Balancer
   |
   v
GKE Gateway
   |
   v
HTTPRoute
   |
   +-- /team-a --> Service team-a --> Pod A
   |
   +-- /team-b --> Service team-b --> Pod B
```

Both paths eventually returned HTTP 200.

---

# 6. Backend Health

The Kubernetes Services and EndpointSlices were healthy.

Google Cloud backend health showed:

```text
team-a → HEALTHY
team-b → HEALTHY
```

Before the health checks stabilized, external requests failed even though:

```text
Gateway PROGRAMMED=True
HTTPRoute Accepted=True
HTTPRoute ResolvedRefs=True
HTTPRoute Reconciled=True
```

After backend health became HEALTHY:

```text
/team-a → HTTP 200
/team-b → HTTP 200
```

---

# 7. Ingress vs Gateway API

Ingress combines infrastructure and routing configuration more closely.

```text
Ingress
 |
 +-- Load Balancer
 +-- Host/path routing
 +-- Backend Services
```

Gateway API separates responsibilities.

```text
Platform Team
     |
     v
  Gateway
     |
     +----------------+
     |                |
 HTTPRoute         HTTPRoute
 Team A             Team B
     |                |
 Service A          Service B
```

This makes Gateway API particularly useful for:

```text
platform teams
shared infrastructure
multi-team environments
multi-tenant routing
advanced traffic management
```

---

# 8. Gateway API Resource Model

```text
GatewayClass
     |
     v
Gateway
     |
     v
HTTPRoute
     |
     v
Service
     |
     v
Pod
```

## GatewayClass

Defines the implementation used for the Gateway.

In GKE this maps to Google-managed load-balancing implementations.

## Gateway

Represents the traffic entry point.

Examples:

```text
listener
port
protocol
route permissions
```

## HTTPRoute

Defines application routing.

Examples:

```text
host
path
backend
traffic rules
```

---

# 9. Multi-Tenant Architecture

This lab used one HTTPRoute in one namespace, so it demonstrated:

```text
shared Gateway
+
multi-service routing
```

A stronger multi-tenant design normally uses:

```text
shared Gateway
     |
     +-- namespace team-a
     |      |
     |      +-- HTTPRoute
     |
     +-- namespace team-b
            |
            +-- HTTPRoute
```

The platform team can own the Gateway while application teams own their routes.

---

# Key Lessons Learned

```text
ClusterIP
→ Internal stable Service IP

NodePort
→ ClusterIP plus a port exposed on each Node

GatewayClass
→ Defines which Gateway implementation is used

Gateway
→ Owns the traffic entry infrastructure

HTTPRoute
→ Owns application Layer 7 routing

Gateway API
→ Separates infrastructure ownership from application routing
```

A configured Gateway may exist before its Load Balancer backends are healthy.

Always distinguish:

```text
resource accepted
resource programmed
backend healthy
application reachable
```

---

# Cost Strategy

The lab used:

```text
1 zonal GKE Standard cluster
1 e2-small node
1 external Layer 7 Load Balancer
No GKE observability stack
No second Load Balancer for Ingress
```

All resources are removed after the exercise.
