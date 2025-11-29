##############################################################
# OUTPUTS
##############################################################

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.id
}

output "ampls_id" {
  description = "Resource ID of the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.ampls.id
}

output "private_endpoint_ip" {
  description = "Private IP of the Azure Monitor Private Endpoint."
  value       = azurerm_private_endpoint.monitor_pe.private_service_connection[0].private_ip_address
}

output "dcr_id" {
  description = "Resource ID of the DCR used for disk metrics."
  value       = azurerm_monitor_data_collection_rule.disk.id
}

output "action_group_id" {
  description = "ID of the Action Group used for alerting."
  value       = azurerm_monitor_action_group.disk.id
}
