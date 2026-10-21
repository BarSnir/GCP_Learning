cat > README.md <<'EOF'
# GKE Exercise 6 — Observability

## Goal

Build a complete observability flow for workloads running on GKE.

The exercise covers:

- GKE workload logs
- Structured logging
- Cloud Logging
- Cloud Monitoring
- Managed Service for Prometheus
- Custom Prometheus metrics
- OpenTelemetry tracing
- Cloud Trace
- Log routing to Pub/Sub
- Log-based alerts

## Architecture

```text
GKE Workload
 |
 +---- stdout / stderr
 |          |
 |          v
 |     Cloud Logging
 |          |
 |          +---- Log-based Alert
 |          |
 |          +---- Logging Sink
 |                   |
 |                   v
 |                Pub/Sub
 |
 +---- /metrics
 |          |
 |          v
 |   Managed Prometheus
 |          |
 |          v
 |   Cloud Monitoring
 |
 +---- OpenTelemetry
            |
            v
       Cloud Trace
```

## GKE Configuration

```text
Cloud Logging:
  SYSTEM_COMPONENTS
  WORKLOADS

Cloud Monitoring:
  SYSTEM_COMPONENTS

Managed Prometheus:
  ENABLED
```

## Cost Strategy

This exercise intentionally enables observability services.

To keep costs low:

- One zonal Standard GKE cluster
- One e2-small worker
- Small test workload
- Short-lived log and trace generation
- No public Load Balancer
- All exercise resources destroyed after completion
EOF
---

# Results

## 1. GKE Workload Logging

GKE workload logging was enabled with:

```text
SYSTEM_COMPONENTS
WORKLOADS
```

Applications wrote structured JSON directly to stdout.

Example:

```json
{
  "severity": "INFO",
  "service": "gke-observability-demo",
  "message": "Application is healthy",
  "environment": "lab"
}
```

The GKE logging agent collected the container output and sent it to Cloud Logging.

```text
Application
    |
    | stdout / stderr
    v
Container Runtime
    |
    v
Fluent Bit
    |
    v
Cloud Logging
```

No logging agent was required inside the application container.

---

## 2. Structured Logging

Cloud Logging parsed JSON logs into searchable fields such as:

```text
jsonPayload.service
jsonPayload.message
jsonPayload.environment
severity
```

This allows queries against structured fields instead of searching raw text.

---

## 3. Managed Prometheus

The metrics workload exposed:

```text
/metrics
```

with the custom metric:

```text
gke_ex6_requests_total 42
```

A PodMonitoring resource selected Pods using:

```yaml
selector:
  matchLabels:
    app: metrics-demo
```

and scraped:

```text
port: metrics
path: /metrics
interval: 30s
```

The metric was successfully queried through the Managed Prometheus PromQL API.

Observed result:

```text
gke_ex6_requests_total = 42
```

Architecture:

```text
Application
    |
    | /metrics
    v
PodMonitoring
    |
    v
Managed Service for Prometheus
    |
    v
Cloud Monitoring
```

---

## 4. OpenTelemetry

Managed OpenTelemetry for GKE was enabled.

The cluster created a managed collector in:

```text
gke-managed-otel
```

The telemetry generator sent OTLP data to the collector.

```text
Telemetry Generator
        |
        | OTLP / gRPC :4317
        v
Managed OpenTelemetry Collector
        |
        v
Google Cloud Observability
```

Cloud Trace successfully returned spans including:

```text
lets-go
```

and child spans such as:

```text
okey-dokey-0
```

The traces contained Kubernetes resource attributes including:

```text
cluster
namespace
pod
deployment
node
zone
service
```

---

## 5. Logging Sink to Pub/Sub

Cloud Logging was configured with a sink selecting:

```text
resource.type="k8s_container"
resource.labels.cluster_name="gke-ex6"
jsonPayload.service="gke-observability-demo"
```

The sink published matching log entries into:

```text
Pub/Sub Topic:
gke-ex6-logs
```

and they were consumed through:

```text
gke-ex6-logs-sub
```

Architecture:

```text
GKE
 |
 v
Cloud Logging
 |
 v
Logging Sink
 |
 v
Pub/Sub Topic
 |
 v
Subscription
```

---

## 6. Log-Based Alerting

A Cloud Monitoring alert policy was created for:

```text
resource.type="k8s_container"
resource.labels.cluster_name="gke-ex6"
jsonPayload.service="gke-observability-demo"
severity>=ERROR
```

The policy was enabled and configured to react to matching application ERROR logs.

No external notification channel was configured for the lab.

---

# Observability Mental Model

```text
                         GKE Application
                               |
          +--------------------+--------------------+
          |                    |                    |
          v                    v                    v
       stdout               /metrics               OTLP
          |                    |                    |
          v                    v                    v
     Fluent Bit          PodMonitoring        OTel Collector
          |                    |                    |
          v                    v                    v
   Cloud Logging       Managed Prometheus       Cloud Trace
          |
          +--------------------+
          |                    |
          v                    v
    Logging Sink        Alert Policy
          |
          v
       Pub/Sub
```

---

# Logs vs Metrics vs Traces

## Logs

Answer:

```text
What happened?
```

Examples:

```text
Application started
Request failed
Database timeout
```

## Metrics

Answer:

```text
How much / how often?
```

Examples:

```text
request rate
CPU usage
latency
error count
```

## Traces

Answer:

```text
Where did a request spend its time?
```

They connect operations across services using a shared trace context.

---

# Key Architecture Takeaways

```text
Logs    → events
Metrics → numbers over time
Traces  → request path
```

All three together provide observability.

Applications should normally emit telemetry while the platform handles collection and export.

---

# Cost Strategy

This exercise intentionally enabled several observability products:

- Cloud Logging
- Cloud Monitoring
- Managed Prometheus
- Managed OpenTelemetry
- Cloud Trace
- Pub/Sub

Costs were minimized by:

- Using one small zonal GKE cluster
- Using one e2-small worker normally
- Temporarily using a second node only when required
- Generating telemetry for a short period
- Avoiding a public Load Balancer
- Destroying the complete environment after the lab
