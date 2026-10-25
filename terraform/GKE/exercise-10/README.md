# Exercise 10 — GKE Security & Governance

## Goal

Practice important GKE security concepts and review governance capabilities relevant to the Google Cloud Professional Cloud Architect exam.

## Architecture

- Zonal Standard GKE cluster
- Custom VPC and subnet
- VPC-native Pod and Service ranges
- Dedicated node Service Account
- Workload Identity Federation
- Shielded GKE Nodes
- Secure Boot
- Integrity Monitoring

## Hands-On Topics

### Shielded GKE Nodes

The cluster was configured with Shielded GKE Nodes enabled.

The node VM was configured with:

- Secure Boot
- Integrity Monitoring

Verification confirmed:

- `shieldedNodes.enabled = true`
- Secure Boot = enabled
- Integrity Monitoring = enabled
- Kubernetes node = Ready

### Kubernetes Secrets

A Kubernetes Secret was created using `stringData`.

When retrieved through the Kubernetes API, the values appeared Base64 encoded.

Base64 is encoding, not encryption.

### GKE Application-Layer Encryption

The cluster reported:

```text
databaseEncryption.state = DECRYPTED
