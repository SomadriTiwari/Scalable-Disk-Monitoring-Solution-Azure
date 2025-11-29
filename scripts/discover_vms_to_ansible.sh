#!/usr/bin/env bash
# Discover Azure VMs and write to ansible/inventory/hosts.ini

set -euo pipefail

OUTPUT_FILE="ansible/inventory/hosts.ini"
SUBSCRIPTIONS=("<sub-id-1>" "<sub-id-2>")

> "$OUTPUT_FILE"

echo "[windows]" >> "$OUTPUT_FILE"
echo "[linux]" >> "$OUTPUT_FILE"

for SUB in "${SUBSCRIPTIONS[@]}"; do
  echo "Processing subscription: $SUB" 1>&2
  az account set --subscription "$SUB"

  # Linux VMs
  az vm list -d --query "[?storageProfile.osDisk.osType=='Linux'].{name:name,ip:privateIps,id:id}" -o tsv \
    | while IFS=$'	' read -r NAME IP ID; do
        echo "${IP} ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_host_resource_id=${ID}" >> "$OUTPUT_FILE"
      done

  # Windows VMs
  az vm list -d --query "[?storageProfile.osDisk.osType=='Windows'].{name:name,ip:privateIps,id:id}" -o tsv \
    | while IFS=$'	' read -r NAME IP ID; do
        echo "${IP} ansible_user=Admin ansible_password=ChangeMe! ansible_connection=winrm ansible_winrm_server_cert_validation=ignore ansible_host_resource_id=${ID}" >> "$OUTPUT_FILE"
      done

done

echo "Inventory written to $OUTPUT_FILE"
```

Run:
```bash
chmod +x scripts/discover_vms_to_ansible.sh
./scripts/discover_vms_to_ansible.sh
