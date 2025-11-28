## 🚀 Scalable Azure Disk Monitoring Solution (Windows VMs Only)
A reusable, multi‑subscription, enterprise‑grade disk monitoring solution for **Azure Windows Virtual Machines**, fully automated using **Terraform + Ansible**.


This project enables **centralized disk utilization monitoring** for any organization while ensuring:
- ✔ Multi‑subscription scalability
- ✔ Secure onboarding using Managed Identity
- ✔ Log Analytics + DCR‑based metric collection
- ✔ Alerts on low disk space
- ✔ Ansible‑driven automation to onboard Windows VMs cleanly
- ✔ Repeatable and organization‑wide rollout


---


## 🎯 Objective
Monitor **disk free percentage** across all Windows VMs in Azure and trigger alerts when thresholds fall below safe levels.


This solution can be deployed for **any enterprise** regardless of how many:
- Tenants
- Subscriptions
- Resource Groups
- Windows VMs


---


## 🧩 High‑Level Architecture
The architecture image is placed at:
```
architecture/azure_windows_disk_monitoring.png
```


### Components
| Component | Purpose |
|----------|---------|
| **Log Analytics Workspace (LAW)** | Stores disk metrics collected from VMs |
| **Data Collection Rule (DCR)** | Defines what disk counters Windows sends |
| **AMA (Azure Monitor Agent)** | Installed on all Windows VMs |
| **Ansible** | Automates AMA installation + VM onboarding + scheduled disk script |
| **Terraform** | Deploys LAW, Alerts, DCR, and VM associations |
| **Scheduled PS Script** | Writes disk usage metrics into Windows Event Log |
| **KQL Alert Rule** | Fires when free disk < threshold |


---


## 🏗️ Repo Structure
```
Scalable-Azure-Disk-Monitoring/
├── architecture/ # PNG diagram
├── infra/terraform/ # Terraform IaC
├── ansible/ # Ansible onboarding automation
└── scripts/ # Helper scripts
```
