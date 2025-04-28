terraform {
  backend "azurerm" {
    resource_group_name  = "Free-tier"
    storage_account_name = "isaacazuretest1"
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
  tags = { env = "testing" }
  
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "Sentinel-LAW"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "example" {
  workspace_id = azurerm_log_analytics_workspace.example.id
}

module "sentinel_rules" {
  source = "./modules/sentinel-rules"

  # Iterate over both security and vm_activity rules and flatten them into a single list
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
}
