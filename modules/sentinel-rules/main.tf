resource "azurerm_sentinel_alert_rule_scheduled" "this" {
  name                       = var.name
  display_name               = var.display_name
  severity                   = var.severity
  log_analytics_workspace_id = var.workspace_id
  query                      = var.query
}