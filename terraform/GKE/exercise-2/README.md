# GKE Exercise 2 — Microservices, Services & GKE Access

## Goal

Deploy two microservices to GKE and understand how Kubernetes networking and GKE access work in practice.

## Architecture

```text
Internet / Laptop
       |
       | TCP :30080
       v
GCP VPC Firewall
       |
       v
GKE Node
NodePort :30080
       |
       v
Frontend Service
       |
       v
Frontend Pod
       |
       | http://backend:8080
       | Kubernetes DNS
       v
Backend ClusterIP Service
       |
       v
Backend Pod
```

## GCP Infrastructure

- Custom VPC
- Custom subnet
- VPC-native GKE Standard zonal cluster
- One e2-small worker node
- Dedicated node service account
- Artifact Registry
- GCP firewall rule for NodePort access

## Kubernetes Resources

- Backend Deployment
- Backend ClusterIP Service
- Frontend Deployment
- Frontend NodePort Service

## Networking

| Resource | CIDR / Port |
|---|---|
| Nodes | `10.50.0.0/24` |
| Pods | `10.51.0.0/20` |
| Services | `10.52.0.0/24` |
| Frontend NodePort | `30080` |
| Application Port | `8080` |

## Service Discovery

The frontend calls:

```text
http://backend:8080
```

Kubernetes DNS resolves `backend` to the backend Service.

The Service then routes traffic to Pods matching:

```text
app=backend
```

Backend Pods can therefore be recreated with new IP addresses without requiring changes to the frontend.

## Access Patterns

### kubectl

```text
Laptop
  |
  v
GKE Kubernetes API
  |
  v
Kubernetes Resources
```

`gcloud container clusters get-credentials` configures the local kubeconfig.

Most GKE administration should be done through Kubernetes APIs and `kubectl`.

### ClusterIP

Internal Kubernetes Service used for communication between workloads inside the cluster.

### NodePort

Exposes a Service through a port on the Kubernetes nodes.

```text
<Node External IP>:30080
```

A GCP firewall rule is required to allow external traffic to the NodePort.

## Cost Strategy

- One zonal Standard cluster
- One e2-small worker node
- No GCP Load Balancer
- Cloud Logging and Monitoring disabled
- NodePort used instead of a LoadBalancer Service
- All lab resources destroyed after completion

## Key Takeaways

- Pods are ephemeral; Services provide stable access.
- Kubernetes DNS provides service discovery.
- ClusterIP is intended for internal cluster traffic.
- NodePort exposes a Service through the nodes.
- GCP firewall rules still apply to NodePort traffic.
- `kubectl` communicates with the Kubernetes API; SSH to nodes is normally unnecessary.
