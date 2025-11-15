# Call Center High Availability Platform

## 🎯 Project Overview

**Mission:** Migrate a mission-critical call center serving 200+ agents from physical servers to a modern OpenShift platform with **zero downtime** and **enterprise-grade reliability**.

**Challenge:** How do you move a live phone system that can't afford even minutes of downtime to a new platform while maintaining 99.95% availability?

**Solution:** A carefully orchestrated migration to OpenShift supporting both virtual machines (for stable VoIP services) and containers (for modern applications).

---

## 📊 Business Impact

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **System Uptime** | 99.5% | 99.95% | +0.45% |
| **Recovery Time** | 4 hours | 15 minutes | **-94% faster** |
| **Infrastructure Cost** | $100k/year | $60k/year | **-40% savings** |
| **Deployment Speed** | Monthly | Daily | **30x faster** |

---

## 🏗️ Architecture Overview

### What We Built
📞 Call Center Platform
├── 🏢 PBX VoIP System (Virtual Machine)
├── 📊 VICIdial Call Center (Virtual Machine)
├── 🔄 ERP System (Containers - Future)
├── 📈 Custom CRM (Containers - Future)
└── 🛡️ High Availability Infrastructure


### The Technology Stack
- **Platform:** Red Hat OpenShift 4.12
- **Virtualization:** OpenShift Virtualization (KubeVirt)
- **Storage:** Ceph with triple replication
- **Networking:** Dual 10GbE fabric with load balancing
- **Monitoring:** Prometheus + Grafana + AlertManager
- **Backup:** Velero with cross-cluster replication

---

## 🎨 Visual Architecture

### High-Level Design
```mermaid
graph TB
    subgraph "Internet & SIP Trunks"
        SIP[Primary SIP Trunk]
        SIP2[Backup SIP Trunk]
    end
    
    subgraph "Firewall & Load Balancer"
        FW[HAProxy Load Balancer]
    end
    
    subgraph "OpenShift Cluster"
        subgraph "Rack 1"
            M1[Master 1]
            W1[Worker 1 - PBX VM]
            I1[Infra 1]
        end
        
        subgraph "Rack 2" 
            M2[Master 2]
            W2[Worker 2 - VICIdial VM]
            I2[Infra 2]
        end
        
        subgraph "Rack 3"
            M3[Master 3]
            W3[Worker 3 - Backup VMs]
            W4[Worker 4 - Containers]
        end
    end
    
    subgraph "Storage"
        CEPH[Ceph Storage Cluster]
    end
    
    SIP --> FW
    SIP2 --> FW
    FW --> W1
    FW --> W2
    W1 -.-> CEPH
    W2 -.-> CEPH
    W3 -.-> CEPH
    W4 -.-> CEPH