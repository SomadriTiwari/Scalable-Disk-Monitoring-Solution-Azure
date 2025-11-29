variable "subscription_id" {
description = "Subscription hosting monitoring resources"
type = string
}


variable "resource_group_name" {
description = "Monitoring resource group"
type = string
}


variable "location" {
description = "Region for monitoring resources"
type = string
}


variable "hub_vnet_id" {
description = "VNet used for private DNS zone link"
type = string
}


variable "hub_subnet_id" {
description = "Subnet where Private Endpoint will be deployed"
type = string
}


variable "name_prefix" {
type = string
default = "diskmon"
}


variable "alert_email" {
description = "Email for action group alerts"
type = string
}


variable "disk_threshold_percent" {
description = "Minimum free space percentage before alert triggers"
type = number
default = 10
}


variable "law_retention_days" {
description = "Retention period for Log Analytics Workspace"
type = number
default = 30
}