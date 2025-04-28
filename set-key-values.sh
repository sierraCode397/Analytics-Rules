#!/bin/bash

KEYVAULT_NAME="terraform123"  # 🔁 change this

export ARM_CLIENT_ID=$(az keyvault secret show --vault-name terraform123 --name "ARM-CLIENT-ID" --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name terraform123 --name "ARM-CLIENT-SECRET" --query value -o tsv)
export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --vault-name terraform123 --name "ARM-SUBSCRIPTION-ID" --query value -o tsv)
export ARM_TENANT_ID=$(az keyvault secret show --vault-name terraform123 --name "ARM-TENANT-ID" --query value -o tsv)

echo "✅ Azure credentials loaded from Key Vault."