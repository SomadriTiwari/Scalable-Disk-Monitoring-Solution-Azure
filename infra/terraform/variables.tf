##############################################################
# REQUIRED VARIABLES
##############################################################

variable "subscription_id" {
  description = "Azure Subscription ID where the monitoring stack is deployed."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where monitoring resources (LAW, AMPLS, DCR, PE) will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region for deployment (e.g. eastus, centralindia)."
  type        = string
}

variable "hub_vnet_id" {
  description = "Resource ID of the Hub Virtual Network used for private endpoint DNS linking."
  type        = string
}

variable "hub_subnet_id" {
  description = "Resource ID of the Hub Subnet where the Azure Monitor Private Endpoint will be created."
  type        = string
}

variable "alert_email" {
  description = "Email address to receive low disk alerts."
  type        = string
}

##############################################################
# OPTIONAL / PARAMETERIZED VARIABLES
##############################################################

variable "name_prefix" {
  description = "Prefix added to all resource names for consistency."
  type        = string
  default     = "diskmon"
}

variable "environment" {
  description = "Environment label (e.g., dev, uat, prod). Used for tagging."
  type        = string
  default     = "prod"
}

variable "disk_threshold_percent" {
  description = "Threshold percentage for low disk alert."
  type        = number
  default     = 10
}

variable "law_retention_days" {
  description = "Retention period for Log Analytics Workspace data."
  type        = number
  default     = 30
}
