##############################################################
# PROVIDER
##############################################################
provider "azurerm" {
  features {}
}

##############################################################
# LOG ANALYTICS WORKSPACE
##############################################################
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.law_retention_days
}

##############################################################
# AMPLS (Azure Monitor Private Link Scope)
##############################################################
# NOTE: AMPLS does NOT take a location field (it's global)
resource "azurerm_monitor_private_link_scope" "ampls" {
  name                = "${var.name_prefix}-ampls"
  resource_group_name = var.resource_group_name

  tags = {
    environment = var.environment
  }
}

resource "azurerm_monitor_private_link_scoped_service" "ampls_law" {
  name                = "law-scope"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.ampls.name
  linked_resource_id  = azurerm_log_analytics_workspace.law.id
}

##############################################################
# PRIVATE DNS ZONE + VNET LINK
##############################################################
resource "azurerm_private_dns_zone" "monitor" {
  name                = "privatelink.monitor.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "${var.name_prefix}-dnslink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = var.hub_vnet_id
}

##############################################################
# PRIVATE ENDPOINT (to AMPLS)
##############################################################
resource "azurerm_private_endpoint" "monitor_pe" {
  name                = "${var.name_prefix}-monitor-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.hub_subnet_id

  private_service_connection {
    name                           = "monitor-ingestion"
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }
}

##############################################################
# DATA COLLECTION RULE (DCR) – DISK METRICS
##############################################################
resource "azurerm_monitor_data_collection_rule" "disk" {
  name                = "${var.name_prefix}-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Windows"   # or "Linux" or "Direct" – Windows works for disk metrics

  destinations {
    log_analytics {
      name                  = "la"
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
    }
  }

  data_sources {
    performance_counter {
      name                          = "diskPerf"
      streams                       = ["Microsoft-Perf"]
      counter_specifiers            = [
        "\\LogicalDisk(*)\\Free Megabytes",
        "\\LogicalDisk(*)\\% Free Space"
      ]
      sampling_frequency_in_seconds = 60
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["la"]
  }
}


##############################################################
# ACTION GROUP – NOTIFICATIONS
##############################################################
resource "azurerm_monitor_action_group" "disk" {
  name                = "${var.name_prefix}-ag"
  resource_group_name = var.resource_group_name
  short_name          = "diskag"

  email_receiver {
    name          = "disk-alert-email"
    email_address = var.alert_email
  }
}

##############################################################
# ALERT – LOW DISK SPACE (QUERY ALERT)
##############################################################
resource "azurerm_monitor_scheduled_query_rule_alert" "low_disk" {
  name                = "${var.name_prefix}-disk-alert"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Alert when disk free space falls below threshold."
  enabled             = true

  # LAW is the log data source for the query
  data_source_id = azurerm_log_analytics_workspace.law.id

  # Query: find VMs where free disk percentage < threshold in last 10 mins
  query = <<-EOF
    InsightsMetrics
    | where Namespace == "LogicalDisk"
    | where Name == "Free Space Percentage"
    | summarize AggregatedValue = avg(Val) by Computer, bin(TimeGenerated, 5m)
    | where AggregatedValue < ${var.disk_threshold_percent}
  EOF

  time_window = "PT10M"   # Look back 10 minutes
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
