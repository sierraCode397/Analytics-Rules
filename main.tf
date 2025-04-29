terraform {
  backend "azurerm" {
    resource_group_name  = "Free-tier"
    storage_account_name = "isaacazuretest"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "Sentinel"
  location = "Central US"
  tags     = { env = "testing" }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "Sentinel-LAW"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "example" {
  # Use the workspace’s resource ID:
  workspace_id = azurerm_log_analytics_workspace.example.id
}

module "sentinel_rules" {
  source = "./modules/sentinel-rules"

  # Flatten both rule lists into one map
  for_each = {
    for idx, rule in flatten([
      local.rules_vm_activity,
      local.rules_security,
    ]) : "${rule.name}-${idx}" => rule
  }

  name         = each.value.name
  display_name = each.value.display_name
  severity     = each.value.severity
  query        = each.value.query
  workspace_id = azurerm_log_analytics_workspace.example.id

  # THIS IS THE KEY: force Terraform to wait for onboarding
  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.example
  ]
}