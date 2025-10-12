# OpenShift/ K8s Platform

<!-- Badges -->
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![OpenShift](https://img.shields.io/badge/openshift-4.x-red)
![GitOps](https://img.shields.io/badge/gitops-argocd-blue)
![CI/CD](https://img.shields.io/badge/tekton-pipelines-orange)
![Maintained](https://img.shields.io/badge/maintained-yes-green)
---

## 📖 Overview
This repository provides an **OpenShift platform** design using **GitOps with ArgoCD**, **Tekton CI/CD pipelines**, and **monitoring** with Prometheus, Grafana, and Alertmanager.  

The same can also be applied to a kubernetes cluster.

It is designed to showcase **99.95% uptime architecture** principles, automation-first deployment, and cloud-native observability.  

**Problem Statement:** Many OpenShift/Kubernetes environments lack a consistent, automated GitOps-driven workflow and reliable monitoring setup.  

**Solution:** This project provides a **modular reference implementation** with reusable manifests, pipelines, and monitoring configurations — deployable on **OpenShift CRC (local dev)** or **Red Hat OpenShift Sandbox (cloud)** or **K3/K8 setup**.  

---

## ✨ Features
- ✅ **GitOps with ArgoCD** → Manage apps declaratively and sync changes automatically.  
- ✅ **Tekton Pipelines** → CI/CD automation (build, test, deploy workflows).  
- ✅ **Observability Stack** → Prometheus metrics, Grafana dashboards, Alertmanager alerts.  
- ✅ **Sample Applications** → Demo microservices for testing GitOps + pipelines.  
- ✅ **Security & RBAC** → Least privilege RBAC for developers vs operators.  
- ✅ **99.95% Uptime Design** → Documentation on HA setup and scaling principles.  

---

## 🏗️ Architecture
```mermaid
graph TB
    subgraph "Developer Workflow"
        DEV[Developer] -->|git push| GH[GitHub Repository]
    end
    
    subgraph "OpenShift Cluster"
        subgraph "CI/CD Layer"
            GH -->|webhook trigger| TEKTON[Tekton Pipeline]
            TEKTON -->|build image| BUILD[Build Pod]
            BUILD -->|push image| REG[Internal Registry]
        end
        
        subgraph "GitOps Layer"
            GH -->|sync manifests| ARGO[ArgoCD]
            ARGO -->|deploy| APPS[Application Pods]
            REG -->|pull image| APPS
        end
        
        subgraph "Monitoring Layer"
            APPS -->|metrics| PROM[Prometheus]
            PROM -->|visualize| GRAF[Grafana]
            PROM -->|alerts| ALERT[Alertmanager]
            ALERT -->|notify| SLACK[Slack/Email]
        end
        
        subgraph "Ingress Layer"
            ROUTE[OpenShift Routes] -->|traffic| APPS
        end
    end
    
    subgraph "External Access"
        USER[End Users] -->|HTTPS| ROUTE
    end
    
    style DEV fill:#4a90e2
    style GH fill:#333
    style TEKTON fill:#ff6d00
    style ARGO fill:#ef7b4d
    style PROM fill:#e6522c
    style GRAF fill:#f46800
    style APPS fill:#326ce5


**Flow:**  
1. Developer pushes code → GitHub  
2. Tekton builds & tests → pushes image to OpenShift registry  
3. ArgoCD syncs manifests from GitHub → deploys to OpenShift  
4. Monitoring stack observes system health → alerts on downtime  

---

## 🚀 Quick Start

### 🔹 Prerequisites
- [OpenShift CRC](https://developers.redhat.com/products/codeready-containers/overview) **or** [OpenShift Sandbox](https://developers.redhat.com/developer-sandbox)  
- `oc` CLI (v4.x)  (Instructions to install are in the documentation)
- `kubectl` (optional)  
- GitHub / Gitlab account (for repo + Actions)  

### 🔹 Installation

Clone this repo:
```bash
git clone https://github.com/blessing-bester/Openshift-production-platform.git
cd Openshift-production-platform

Deploy ArgoCD:
oc apply -f manifests/argocd/

Deploy Tekton Pipelines:
oc apply -f manifests/tekton/

Deploy Monitoring:
oc apply -f manifests/monitoring/

Deploy Your Applications:
oc apply -f manifests/sample-apps/



