variable "workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID"
}

variable "name" {
  type        = string
  description = "Unique name for the alert rule"
}

variable "display_name" {
  type        = string
  description = "Human-friendly display name"
}

variable "severity" {
  type        = string
  description = "Alert severity (e.g. High, Medium, Low)"
}

variable "query" {
  type        = string
  description = "Kusto query for the rule"
}
