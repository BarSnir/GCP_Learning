
---

# Exercise 3 - Managed Cloud Service Mesh Foundations

## What We Built

- GKE Standard cluster
- Fleet membership
- Managed Cloud Service Mesh
- Managed control plane using TRAFFIC_DIRECTOR
- Managed data plane
- Automatic Envoy sidecar injection
- Two mesh workloads: caller and echo
- STRICT mTLS enforcement

## Architecture

Google Managed Control Plane
        |
        | xDS configuration
        v
caller Pod
├── caller
└── istio-proxy (Envoy)
        |
        | mTLS
        v
echo Pod
├── nginx
└── istio-proxy (Envoy)

## Validation

Managed Service Mesh reached:

- Control Plane: ACTIVE
- Implementation: TRAFFIC_DIRECTOR
- Data Plane: ACTIVE
- ControlPlaneRevision RECONCILED=True
- ControlPlaneRevision STALLED=False

Both application Pods contained two containers:

- application container
- istio-proxy

The caller successfully reached echo through the mesh.

Proxy configuration showed that Envoy received dynamic service configuration from the managed control plane.

Envoy also contained a valid workload certificate and ROOTCA.

## mTLS

A mesh-wide PeerAuthentication policy was configured:

mtls:
  mode: STRICT

Traffic from caller inside the mesh continued to work:

HTTP 200

Traffic from a Pod without an Envoy sidecar failed:

Connection reset by peer

This demonstrated that plaintext traffic was rejected while authenticated mesh traffic continued to work.

## Troubleshooting and Lessons Learned

### Wrong kubectl context

kubectl initially still pointed to the deleted Exercise 2 cluster.

Fix:

gcloud container clusters get-credentials mesh-gke \
  --zone europe-west1-b \
  --project pca-certifciation

Lesson:

Always establish and verify the kubectl context immediately after cluster creation.

### Managed control plane provisioning

The Service Mesh feature initially reported:

REVISION_PROVISIONING

Instead of waiting blindly, ControlPlaneRevision was inspected:

kubectl get controlplanerevision -n istio-system

Successful state:

RECONCILED=True
STALLED=False

### proxy-config required istioctl

The gcloud mesh debugging command required istioctl locally.

Installed with:

gcloud components install istioctl

### Empty shell variable

CALLER_POD was lost after changing shell context.

The resulting proxy-config command attempted to use:

.mesh-demo

instead of:

POD_NAME.mesh-demo

Lesson:

Validate shell variables before using them in debugging commands.

### STRICT mTLS debugging

The namespace PeerAuthentication resource was Accepted, but plaintext traffic still succeeded during testing.

Instead of assuming propagation, we verified:

- Proxy synchronization
- All PeerAuthentication policies
- Envoy certificates
- Listener configuration

Both proxies were SYNCED and certificates were valid.

A mesh-wide STRICT policy in istio-system was then tested and plaintext traffic was rejected successfully.

Lesson:

Kubernetes resource Accepted does not necessarily prove that the data plane is enforcing the intended behavior.

Validate behavior from the actual Envoy data plane.

## Key Concepts

- Control Plane distributes configuration.
- Envoy proxies form the Data Plane.
- xDS dynamically configures Envoy.
- Service Mesh does not merge Kubernetes services.
- Sidecar injection places Envoy beside the application container.
- Auto-mTLS enables secure communication between mesh workloads.
- STRICT mTLS rejects plaintext connections.
- Workload certificates provide identity to mesh workloads.
- Managed Cloud Service Mesh removes the need to operate Istiod ourselves.

## Final Result

Control Plane: ACTIVE
Data Plane: ACTIVE
Envoy Injection: Working
Service-to-Service Traffic: Working
mTLS: Working
Plaintext Traffic: Rejected

Exercise 3 completed successfully.
