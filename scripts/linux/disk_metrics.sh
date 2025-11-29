#!/bin/bash
for mount in $(df -h | awk 'NR>1{print $6}'); do
  free_pct=$(df -h | awk -v m="$mount" '$6==m {print $5}' | sed 's/%//')
  logger -t diskmon "Mount: $mount Free: ${free_pct}%"
done
