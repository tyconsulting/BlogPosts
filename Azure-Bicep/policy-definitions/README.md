# Policy Definitions

Demo template for the Policy Definition Bicep module

This template deploys the policy definitions to the a management group.

## Outputs

Name | Type | Description
---- | ---- | -----------
policyDefinitions | array |

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "./templates/policy-definitions/main.json"
    },
    "parameters": {}
}
```

