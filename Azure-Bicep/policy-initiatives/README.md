# Policy Initiatives

Demo template for the Policy Initiative Bicep module

This template deploys the policy initiatives in a management group.

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
managementGroupId | No       | Policy Definition Source Management Group Id

### managementGroupId

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Policy Definition Source Management Group Id

- Default value: `[managementGroup().id]`

## Outputs

Name | Type | Description
---- | ---- | -----------
policySetDefinitions | array |

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "./templates/policy-initiatives/main.json"
    },
    "parameters": {
        "managementGroupId": {
            "value": "[managementGroup().id]"
        }
    }
}
```

