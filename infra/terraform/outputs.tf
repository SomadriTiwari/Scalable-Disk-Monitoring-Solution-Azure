output "log_analytics_workspace_id" {
value = azurerm_log_analytics_workspace.law.id
}


output "ampls_id" {
value = azurerm_monitor_private_link_scope.ampls.id
}


output "private_endpoint_id" {
value = azurerm_private_endpoint.monitor_pe.id
}