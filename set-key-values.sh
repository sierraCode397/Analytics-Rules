#!/bin/bash
set -euo pipefail

# Use KEYVAULT_NAME env var if set, otherwise default to "terraform12"
KEYVAULT_NAME="${KEYVAULT_NAME:-terraform12}"

# Fetch and export each ARM_* secret from the specified Key Vault
export ARM_CLIENT_ID=$(az keyvault secret show \
  --vault-name "$KEYVAULT_NAME" \
  --name "ARM-CLIENT-ID" \
  --query value -o tsv)

export ARM_CLIENT_SECRET=$(az keyvault secret show \
  --vault-name "$KEYVAULT_NAME" \
  --name "ARM-CLIENT-SECRET" \
  --query value -o tsv)

export ARM_SUBSCRIPTION_ID=$(az keyvault secret show \
  --vault-name "$KEYVAULT_NAME" \
  --name "ARM-SUBSCRIPTION-ID" \
  --query value -o tsv)

export ARM_TENANT_ID=$(az keyvault secret show \
  --vault-name "$KEYVAULT_NAME" \
  --name "ARM-TENANT-ID" \
  --query value -o tsv)

echo "✅ Azure credentials loaded from Key Vault: $KEYVAULT_NAME"
