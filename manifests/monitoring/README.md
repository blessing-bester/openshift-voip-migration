# Monitoring Stack Deployment on OpenShift & Kubernetes

## Overview

This guide describes how to deploy a **monitoring stack** on **OpenShift** and **Kubernetes** clusters. The stack includes **Prometheus**, **Grafana**, and **Alertmanager**, supporting both node and application metrics collection.

---

## Components

| Component                              | Purpose                                                    |
| -------------------------------------- | ---------------------------------------------------------- |
| **Prometheus**                         | Collects and stores metrics from nodes, pods, and services |
| **Alertmanager**                       | Manages alerting and notifications (e.g., Slack, Email)    |
| **Grafana**                            | Visualizes metrics and dashboards                          |
| **Node Exporter / Kube State Metrics** | Exposes cluster and node-level metrics                     |
| **ServiceMonitors**                    | CRDs defining services for Prometheus to scrape            |

---

## Prerequisites

Ensure the following before deployment:

- **Cluster-admin** privileges are available.
- **Helm 3** or **Operator Lifecycle Manager (OLM)** is installed.
- The cluster can pull **Prometheus** and **Grafana** container images.
- (Recommended) Create a dedicated namespace for monitoring:

  ```bash
  kubectl create namespace monitoring
  # or
  oc new-project monitoring
  ```

---

## Deployment Notes

- Helm charts are located in the `kub-prometheus-stack` directory.
- Customize the `values.yaml` file before deployment (e.g., set Grafana admin password).
- **Kubernetes**:
  - Consider using a NodePort service to expose Grafana and dashboards.
  - Recommended NodePort range: `30001-30999`.
- **OpenShift**:
  - Expose services using OpenShift `Route` resources or by exposing the service directly.

> **Security Best Practices:**
>
> - Restrict dashboard access.
> - Manage credentials securely.
> - Follow cluster security guidelines for monitoring components.
