# Scalable Azure Disk Monitoring Solution 

A fully **secure**, **cost‑optimized**, and **multi‑subscription scalable** disk monitoring solution leveraging:
- **Azure Monitor Agent (AMA)**
- **Log Analytics Workspace (LAW)**
- **Data Collection Rule (DCR)**
- **Azure Monitor Private Link Scope (AMPLS)**
- **Private Endpoint + Private DNS Zone**
- **Ansible automation** for onboarding VMs
- **Scheduled disk scripts** for Windows & Linux
- **Terraform IaC** for deployment

This README clearly details the **design**, **architecture**, **reasoning**, **steps**, and **artifacts**.

# 🎯 Objective
Build a **scalable, secure, automated disk‑monitoring solution** for Azure VMs (Linux & Windows) that:
1. Uses AMA (Azure Monitor Agent) with a custom DCR for disk metrics
2. Sends telemetry securely via **Private Link (AMPLS)**
3. Triggers alerts when free disk % falls below a threshold
4. Uses Ansible to automate VM onboarding
5. Schedules local disk scripts to generate metrics for ingestion
6. Supports multi‑subscription environments

---
# 🧩 Solution Overview (High-Level)
The solution uses **centralized monitoring** deployed in a **Hub Subscription** while VMs live across multiple **their separate Subscriptions**.

### 🔐 Security-by-Design
✔ AMA traffic flows **privately** to Azure Monitor through AMPLS  
✔ All monitoring components stay inside the customer VNet  
✔ No public endpoints required  
✔ DCR used to standardize disk metrics

### 📡 Scalable Multi-Subscription Monitoring
- Terraform deploys Log Analytics Workspace (LAW), DCR, AMPLS, PE, DNS
- Ansible discovers VMs dynamically across Azure subscriptions
- Azure Policy automatically onboards new VMs into monitoring

### 📊 Disk Metric Strategy
Windows & Linux VMs:
- Write periodic disk information to **Event Log (Windows)** or **Syslog (Linux)**
- AMA collects metrics using DCR performance counters
- Metrics flow to Log Analytics Workspace (LAW)

### Alerting
A Scheduled Query Alert analyzes InsightsMetrics and triggers when disk free % < threshold.

---
# 🏗 Architecture Diagram
See `architecture.png` in the repository root.

The architecture implements these steps:
1. **VMs (Linux/Windows)** across subscriptions run disk scripts + AMA
2. **Ansible** installs AMA and schedules scripts
3. **Terraform (Hub Subscription)** deploys:
   - Log Analytics Workspace (LAW)
   - AMPLS
   - Private DNS Zone
   - Private Endpoint
   - DCR
   - Query-based Disk Alert
4. AMA sends logs **privately** to LAW via AMPLS
5. Alerts fire and notify via Action Groups
6. Azure Policy auto-enrolls future VMs

---
# 📁 Repository Structure
```
Scalable-Disk-Monitoring-Solution-Azure/
├── README.md
├── architecture.png
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   ├── outputs.tf
│   └── versions.tf
│
├── ansible/
│   └── playbooks/
│       ├── install_ama_linux.yaml
│       ├── install_ama_windows.yaml
│       ├── schedule_linux_disk_script.yaml
│       ├── schedule_windows_disk_script.yaml
│       ├── associate_dcr.yaml
│
├── scripts/
|   |--discover_vms_to_ansible.sh
│   ├── windows/disk_metric_eventlog.ps1
│   └── linux/disk_metrics.sh
|    
│
├── policy/
│   └── ama_dcr_autoonboarding.json
│
└── .github/workflows/ci-cd.yml
```

---
# 🧱 Terraform (Infrastructure-as-Code)
Terraform deploys **all core monitoring components** into a single monitoring subscription.

### ✔ Deploys
- Log Analytics Workspace (LAW)
- Azure Monitor Private Link Scope (AMPLS)
- Private Endpoint for Azure Monitor ingestion
- Private DNS Zone for privatelink.monitor.azure.com
- Data Collection Rule (DCR)
- Alert Rule for Low Disk Space
- Action Group (Email)

### 📌 Deployment Steps
```
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

---
# 🔧 Ansible Automation
Ansible handles **all VM-side work**, including installing AMA and setting up scheduled disk scripts.

### ✔ Install AMA on Windows
```
ansible-playbook -i inventory/hosts.ini ansible/playbooks/install_ama_windows.yaml
```

### ✔ Install AMA on Linux
```
ansible-playbook -i inventory/hosts.ini ansible/playbooks/install_ama_linux.yaml
```

### ✔ Schedule Disk Scripts (Windows)
```
ansible-playbook -i inventory/hosts.ini ansible/playbooks/schedule_windows_disk_script.yaml
```

### ✔ Schedule Disk Scripts (Linux)
```
ansible-playbook -i inventory/hosts.ini ansible/playbooks/schedule_linux_disk_script.yaml
```

### ✔ Associate VMs with DCR
```
ansible-playbook -i inventory/hosts.ini ansible/playbooks/associate_dcr.yaml
```

---
# 📝 Scripts for Disk Metrics
### Windows
`scripts/windows/disk_metric_eventlog.ps1`  
Uses EventLog to write free-disk percentage every 5 minutes.

### Linux
`scripts/linux/disk_metrics.sh`  
Writes disk free % to syslog.

These get executed via Ansible’s scheduled tasks/cron jobs.

---
# 🔎 VM Discovery Automation (Azure → Ansible)
To discover all VMs across subscriptions:
```
./scripts/discover_vms_to_ansible.sh
```
This generates a complete `hosts.ini` automatically.


## Azure Workbook (Disk Monitoring Dashboard)
Azure Monitor Workbooks can be used to visualize disk usage trends, low disk space, and VM metrics.
We can create a workbook in Azure Portal using queries such as:
- `InsightsMetrics` for disk free %
- `Perf` for additional counters
 Azure Workbook (Dashboard)
Import dashboard JSON into Azure Monitor Workbooks:
```
workbooks/disk-monitor-workbook.json
```
Provides:
- Lowest free-disk VMs
- Trends over time
- Tables and time charts

---
# ⚙️ CI/CD Pipeline (GitHub Actions)
The workflow automatically:
- Runs Terraform formatting, validation, plan
- Allows manual apply
- It runs Ansible as well to combine the solution and make it 

File:
```
.github/workflows/ci-cd.yml
```


