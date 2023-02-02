# VNet Integrated Cloud Shell Template

Deploys VNet Integrated Cloud Shell pattern. Values for all the parameters in the parameter file must be specified.

This template is used to deploy a Resource Group with a VNet Integrated Cloud Shell in one of the Connectivity subscriptions.

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
location       | No       | Location for all resources.
tags           | No       | Tags
existingVNETName | Yes      | Existing Virtual Network name
privateEndpointSubnetName | Yes      | Existing Private Endpoint Subnet Name
relayNamespaceName | Yes      | Name of Azure Relay Namespace.
relayPrivateEndpointStaticPrivateIPAddress | Yes      | The static privavte IP address for the private endpoint.
azureContainerInstanceOID | Yes      | Object Id of Azure Container Instance Service Principal. We have to grant this permission to create hybrid connections in the Azure Relay you specify. To get it: Get-AzADServicePrincipal -DisplayNameBeginsWith 'Azure Container Instance'
containerSubnetName | No       | Name of the subnet to use for cloud shell containers.
containerSubnetAddressPrefix | Yes      | Address space of the subnet to add for cloud shell. e.g. 10.0.1.0/26
cloudShellStorageAccountName | Yes      | Name of Cloud Shell Storage Account
tagName        | No       | Name of the resource tag.

### location

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Location for all resources.

- Default value: `[resourceGroup().location]`

### tags

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Tags

### existingVNETName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Existing Virtual Network name

### privateEndpointSubnetName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Existing Private Endpoint Subnet Name

### relayNamespaceName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Name of Azure Relay Namespace.

### relayPrivateEndpointStaticPrivateIPAddress

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The static privavte IP address for the private endpoint.

### azureContainerInstanceOID

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Object Id of Azure Container Instance Service Principal. We have to grant this permission to create hybrid connections in the Azure Relay you specify. To get it: Get-AzADServicePrincipal -DisplayNameBeginsWith 'Azure Container Instance'

### containerSubnetName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Name of the subnet to use for cloud shell containers.

- Default value: `CloudShell`

### containerSubnetAddressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Address space of the subnet to add for cloud shell. e.g. 10.0.1.0/26

### cloudShellStorageAccountName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Name of Cloud Shell Storage Account

### tagName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Name of the resource tag.

- Default value: `@{Environment=cloudshell}`

## Outputs

Name | Type | Description
---- | ---- | -----------
vnetId | string |
containerSubnetId | string |
relayNamespaceId | string |
storageAccountId | string |

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "./Azure-Bicep/vnet-isolated-cloud-shell/main.json"
    },
    "parameters": {
        "location": {
            "value": "[resourceGroup().location]"
        },
        "tags": {
            "value": {}
        },
        "existingVNETName": {
            "value": ""
        },
        "privateEndpointSubnetName": {
            "value": ""
        },
        "relayNamespaceName": {
            "value": ""
        },
        "relayPrivateEndpointStaticPrivateIPAddress": {
            "value": ""
        },
        "azureContainerInstanceOID": {
            "value": ""
        },
        "containerSubnetName": {
            "value": "CloudShell"
        },
        "containerSubnetAddressPrefix": {
            "value": ""
        },
        "cloudShellStorageAccountName": {
            "value": ""
        },
        "tagName": {
            "value": {
                "Environment": "cloudshell"
            }
        }
    }
}
```

