# 🚀 Scalable Azure Disk Monitoring Solution (Multi-Subscription, Windows + Linux)

A reusable, enterprise-grade monitoring solution for **Azure Virtual Machines** across **multiple subscriptions**, automated using **Terraform + Ansible**, with **private ingestion** via Azure Monitor Private Link.

This solution enables organizations to:

- ✔ Monitor disk utilization across all VMs  
- ✔ Enforce private ingestion (AMPLS + Private Endpoint)  
- ✔ Standardize Windows & Linux disk metrics  
- ✔ Trigger alerts when disk space is low  
- ✔ Automate onboarding using Ansible  
- ✔ Scale across any number of subscriptions  

---

## 🎯 Objective

To provide a **simple, cost-optimized, secure, and scalable** disk monitoring solution that works across:

- Multiple Azure Subscriptions  
- Multiple VNets  
- Windows & Linux VMs  
- Hub-and-Spoke or Flat Networks  

The goal is early detection of **low disk space** to prevent outages.

---

## 🧩 High-Level Architecture

Architecture diagram is located at:

```
architecture.png

```

### 🔹 Architecture Steps (as shown in the diagram)

#### **Step 1 — VM Layer (Multi-Subscription)**  
- Azure VMs in different subscriptions  
- AMA (Azure Monitor Agent) installed via Ansible  
- Managed Identity enabled  
- Disk metrics collected from Windows & Linux  
- Metrics sent via Private Endpoint  

#### **Step 2 — Hub Monitoring Plane (Hub Subscription)**  
- Log Analytics Workspace (LAW)  
- Azure Monitor Private Link Scope (AMPLS)  
- Private Endpoint for Monitor Ingestion  
- Private DNS Zone (`privatelink.monitor.azure.com`)  
- All ingestion is private-only  

#### **Step 3 — Rules & Alerts**  
- Data Collection Rule (DCR) collects disk metrics  
- Scheduled Query Alert checks low disk %  
- Action Group notifies via Email / Teams / Webhook  
- Terraform deploys monitoring infra  
- Ansible installs AMA & onboards VMs  

---

## 🧱 Components

| Component | Purpose |
|----------|---------|
| Log Analytics Workspace | Stores disk metrics |
| AMPLS | Controls private ingestion |
| Private Endpoint | Secures ingestion path |
| Private DNS Zone | Resolves Monitor endpoints privately |
| DCR | Collects FreeSpaceMB, FreeSpacePercent |
| Scheduled Query Alert | Fires on low disk percentage |
| Action Group | Notification channel |
| Ansible | Installs AMA and enables MI |
| Terraform | Automates all monitoring resources |

---

## 📦 Repository Structure

```plaintext
Scalable-Azure-Disk-Monitoring/
├── architecture.png
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── modules/
│       ├── log_analytics/
│       ├── ampls/
│       ├── private_endpoint/
│       ├── dns_zone/
│       ├── dcr_disk_metrics/
│       ├── alert_low_disk/
│       └── role_assignments/
│
└── ansible/
    ├── install_ama_windows.yml
    ├── install_ama_linux.yml
    ├── roles/
    │   └── ama/
    │       └── tasks/main.yml
    └── inventory/
        └── hosts.ini
```

---

## ⚙️ Deployment Guide

### **1️⃣ Deploy Monitoring Infrastructure Using Terraform**

#### Authenticate

```bash
az login
az account set --subscription <hub_subscription_id>
```

#### Update terraform.tfvars

```hcl
location = "eastus"
hub_subscription_id = "xxxx-xxxx"
hub_resource_group  = "rg-hub-monitoring"

subscriptions = [
  {
    id      = "sub-a-id"
    vnet_id = "/subscriptions/.../vnets/vnet-a"
  },
  {
    id      = "sub-b-id"
    vnet_id = "/subscriptions/.../vnets/vnet-b"
  }
]
```

#### Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

This creates:

- LAW  
- AMPLS  
- Private Endpoint  
- Private DNS Zone  
- Disk Metrics DCR  
- Alert Rule  
- Action Group  

---

## 🛠️ 2️⃣ Onboard VMs Using Ansible

### Add VM Private IPs

Edit:

```
ansible/inventory/hosts.ini
```

Example:

```ini
[windows]
10.10.1.4

[linux]
10.20.3.7
```

### Install AMA on Windows

```bash
ansible-playbook ansible/install_ama_windows.yml -i ansible/inventory/hosts.ini
```

### Install AMA on Linux

```bash
ansible-playbook ansible/install_ama_linux.yml -i ansible/inventory/hosts.ini
```

This installs AMA, enables Managed Identity, and associates VM with the DCR.

---

## 🔍 Validation

### AMA Status

Windows:

```powershell
Get-Service HealthService
```

Linux:

```bash
systemctl status azuremonitoragent
```

### Verify Disk Metrics in Log Analytics

```kql
InsightsMetrics
| where Namespace == "LogicalDisk"
| where Name in ("Free Megabytes", "Free Space Percentage")
| take 10
```

### Validate Alert

- Reduce disk space  
- Alert triggers  
- Action Group notifies team  

---

## 🧭 Customer Onboarding Summary

1. Clone repo  
2. Edit `terraform.tfvars`  
3. Run Terraform  
4. Add VM IPs to Ansible inventory  
5. Run Ansible playbook  
6. Validate ingestion + alerting  

To onboard new VMs later:

**Add IP → run Ansible → done.**

---

## 🏁 Summary

This solution is:

- 🔐 Secure (Private Link + Managed Identity)  
- ⚙️ Automated (Terraform + Ansible)  
- 🔄 Scalable (multi-subscription)  
- 💰 Cost-optimized (single AMPLS + PE)  
- 🧪 Fully tested end-to-end  

A production-ready Azure disk monitoring framework built for enterprise scale.
