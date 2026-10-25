# GKE Exercise 9 — Regional & Multi-Cluster GKE

## Goal

Build a multi-region GKE architecture and understand:

- Regional GKE control planes
- Node locations
- Fleet
- Multi-Cluster Services
- ServiceExport / ServiceImport
- Multi-Cluster Gateway
- Multi Cluster Ingress vs Multi-Cluster Gateway
- Multi-region failover

## Architecture

```text
Shared VPC
 |
 +-- europe-west1
 |     |
 |     +-- Regional GKE cluster
 |           |
 |           +-- one node in europe-west1-b
 |
 +-- europe-west4
       |
       +-- Regional GKE cluster
             |
             +-- one node in europe-west4-a
