locals {
  # Security rules
  rules_security = [
    {
      name         = "unusual-activity"
      display_name = "Unusual Security Activity"
      severity     = "Medium"
      query        = <<QUERY
SecurityEvent
| where EventID == 4625
QUERY
    },
  ]

  # VM activity rules
  rules_vm_activity = [
    {
      name         = "vm-creation-success"
      display_name = "VM Created Successfully"
      severity     = "High"
      query        = <<QUERY
AzureActivity |
  where OperationName == "Create or Update Virtual Machine" or OperationName =="Create Deployment" |
  where ActivityStatus == "Succeeded"
QUERY
    },
  ]
}