# -----------------------------------------------------------
# LOG ANALYTICS WORKSPACE
# -----------------------------------------------------------
resource "azurerm_log_analytics_workspace" "law" {
name = "${var.name_prefix}-law"
location = var.location
resource_group_name = var.resource_group_name
sku = "PerGB2018"
retention_in_days = var.law_retention_days
}


# -----------------------------------------------------------
# AMPLS (Azure Monitor Private Link Scope)
# -----------------------------------------------------------
resource "azurerm_monitor_private_link_scope" "ampls" {
name = "${var.name_prefix}-ampls"
resource_group_name = var.resource_group_name
}


resource "azurerm_monitor_private_link_scoped_service" "ampls_law" {
name = "law-scope"
resource_group_name = var.resource_group_name
scope_name = azurerm_monitor_private_link_scope.ampls.name
linked_resource_id = azurerm_log_analytics_workspace.law.id
}


# -----------------------------------------------------------
# PRIVATE DNS ZONE + VNET LINK
# -----------------------------------------------------------
resource "azurerm_private_dns_zone" "monitor" {
name = "privatelink.monitor.azure.com"
resource_group_name = var.resource_group_name
}


resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
name = "${var.name_prefix}-dnslink"
resource_group_name = var.resource_group_name
private_dns_zone_name = azurerm_private_dns_zone.monitor.name
virtual_network_id = var.hub_vnet_id
}


# -----------------------------------------------------------
# PRIVATE ENDPOINT (to AMPLS)
# -----------------------------------------------------------
resource "azurerm_private_endpoint" "monitor_pe" {
name = "${var.name_prefix}-monitor-pe"
location = var.location
resource_group_name = var.resource_group_name
subnet_id = var.hub_subnet_id


private_service_connection {
name = "monitor-ingestion"
private_connection_resource_id = azurerm_monitor_private_link_scope.ampls.id
subresource_names = ["azuremonitor"]
is_manual_connection = false
}
}


# -----------------------------------------------------------
# DATA COLLECTION RULE (DCR) – Disk Metrics
# -----------------------------------------------------------
resource "azurerm_monitor_scheduled_query_rule_alert" "low_disk" {
  name                = "${var.name_prefix}-disk-alert"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Alert when disk free space falls below threshold."
  enabled             = true

  # Log Analytics Workspace is the data source
  data_source_id = azurerm_log_analytics_workspace.law.id

  query = <<-EOF
    InsightsMetrics
    | where Namespace == "LogicalDisk"
    | where Name == "Free Space Percentage"
    | where Val < ${var.disk_threshold_percent}
    | summarize AggregatedValue = avg(Val) by Computer, bin(TimeGenerated, 5m)
  EOF

  time_window = "PT10M"   # 10 minutes
  frequency   = "PT5M"    # Run every 5 minutes
  severity    = 2
  auto_mitigation_enabled = false

  trigger {
    operator  = "LessThan"
    threshold = var.disk_threshold_percent
  }

  action {
    action_groups = [azurerm_monitor_action_group.disk.id]
  }
}
