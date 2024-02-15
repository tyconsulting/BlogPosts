# Bicep Module - Network Security Group `[Microsoft.Network/networkSecurityGroups]`

This module deploys a standardised Network security Group (NSG).

## Navigation

- [Usage examples](#Usage-examples)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.


- [Using large parameter set](#example-1-using-large-parameter-set)
- [Using only defaults](#example-2-using-only-defaults)

### Example 1: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module networkSecurityGroup 'br/alias:network.network-security-group:<version>' = {
  name: '${uniqueString(deployment().name, location)}-test-nnsgcom'
  params: {
    // Required parameters
    name: 'nnsgcom001'
    // Non-required parameters
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    securityRules: [
      {
        access: 'Allow'
        description: 'Tests specific IPs and ports'
        destination: [
          '*'
        ]
        destinationPort: [
          '8080'
        ]
        direction: 'Inbound'
        name: 'Specific'
        priority: 200
        protocol: '*'
        source: [
          '*'
        ]
        sourcePort: [
          '*'
        ]
      }
      {
        access: 'Allow'
        description: 'Tests Ranges'
        destination: [
          '10.2.0.0/16'
          '10.3.0.0/16'
        ]
        destinationPort: [
          '90'
          '91'
        ]
        direction: 'Inbound'
        name: 'Ranges'
        priority: 210
        protocol: '*'
        source: [
          '10.0.0.0/16'
          '10.1.0.0/16'
        ]
        sourcePort: [
          '80'
          '81'
        ]
      }
      {
        access: 'Allow'
        description: 'Allow inbound access on TCP 8082'
        destination: [
          '<applicationSecurityGroup1ResourceId>'
          '<applicationSecurityGroup2ResourceId>'
        ]
        destinationPort: [
          '8082'
        ]
        direction: 'Inbound'
        name: 'Port_8082'
        priority: 220
        protocol: '*'
        source: [
          '<applicationSecurityGroup3ResourceId>'
        ]
        sourcePort: [
          '*'
        ]
      }
      {
        access: 'Deny'
        description: 'Deny inbound access on TCP 8080'
        destination: [
          '<applicationSecurityGroup1ResourceId>'
          '<applicationSecurityGroup2ResourceId>'
        ]
        destinationPort: [
          '8080'
        ]
        direction: 'Outbound'
        name: 'Port_8080'
        priority: 210
        protocol: '*'
        source: [
          '<applicationSecurityGroup3ResourceId>'
        ]
        sourcePort: [
          '*'
        ]
      }
    ]
    tags: '<tags>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "nnsgcom001"
    },
    // Non-required parameters
    "roleAssignments": {
      "value": [
        {
          "principalId": "<principalId>",
          "principalType": "ServicePrincipal",
          "roleDefinitionIdOrName": "Reader"
        }
      ]
    },
    "securityRules": {
      "value": [
        {
          "access": "Allow",
          "description": "Tests specific IPs and ports",
          "destination": [
            "*"
          ],
          "destinationPort": [
            "8080"
          ],
          "direction": "Inbound",
          "name": "Specific",
          "priority": 200,
          "protocol": "*",
          "source": [
            "*"
          ],
          "sourcePort": [
            "*"
          ]
        },
        {
          "access": "Allow",
          "description": "Tests Ranges",
          "destination": [
            "10.2.0.0/16",
            "10.3.0.0/16"
          ],
          "destinationPort": [
            "90",
            "91"
          ],
          "direction": "Inbound",
          "name": "Ranges",
          "priority": 210,
          "protocol": "*",
          "source": [
            "10.0.0.0/16",
            "10.1.0.0/16"
          ],
          "sourcePort": [
            "80",
            "81"
          ]
        },
        {
          "access": "Allow",
          "description": "Allow inbound access on TCP 8082",
          "destination": [
            "<applicationSecurityGroup1ResourceId>",
            "<applicationSecurityGroup2ResourceId>"
          ],
          "destinationPort": [
            "8082"
          ],
          "direction": "Inbound",
          "name": "Port_8082",
          "priority": 220,
          "protocol": "*",
          "source": [
            "<applicationSecurityGroup3ResourceId>"
          ],
          "sourcePort": [
            "*"
          ]
        },
        {
          "access": "Deny",
          "description": "Deny Outbound access on TCP 8080",
          "destination": [
            "<applicationSecurityGroup1ResourceId>",
            "<applicationSecurityGroup2ResourceId>"
          ],
          "destinationPort": [
            "8080"
          ],
          "direction": "Outbound",
          "name": "Port_8080",
          "priority": 210,
          "protocol": "*",
          "source": [
            "<applicationSecurityGroup3ResourceId>"
          ],
          "sourcePort": [
            "*"
          ]
        }
      ]
    },
    "tags": {
      "value": "<tags>"
    }
  }
}
```

</details>
<p>

### Example 2: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module networkSecurityGroup 'br/alias:network.network-security-group:<version>' = {
  name: '${uniqueString(deployment().name, location)}-test-nnsgmin'
  params: {
    // Required parameters
    name: 'nnsgmin001'
    // Non-required parameters
    tags: '<tags>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "nnsgmin001"
    },
    // Non-required parameters
    "tags": {
      "value": "<tags>"
    }
  }
}
```

</details>
<p>


## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | Name of the Network Security Group. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`flushConnection`](#parameter-flushconnection) | bool | When enabled, flows created from Network Security Group connections will be re-evaluated when rules are updates. Initial enablement will trigger re-evaluation. Network Security Group connection flushing is not available in all regions. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |
| [`securityRules`](#parameter-securityrules) | array | Array of Security Rules to deploy to the Network Security Group. When not provided, an NSG including only the built-in roles will be deployed. |
| [`tags`](#parameter-tags) | object | Tags of the NSG resource. |

### Parameter: `flushConnection`

When enabled, flows created from Network Security Group connections will be re-evaluated when rules are updates. Initial enablement will trigger re-evaluation. Network Security Group connection flushing is not available in all regions.
- Required: No
- Type: bool
- Default: `False`

### Parameter: `location`

Location for all resources.
- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `name`

Name of the Network Security Group.
- Required: Yes
- Type: string

### Parameter: `roleAssignments`

Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.
- Required: No
- Type: array


| Name | Required | Type | Description |
| :-- | :-- | :--| :-- |
| [`condition`](#parameter-roleassignmentscondition) | No | string | Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container" |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | No | string | Optional. Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | No | string | Optional. The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | No | string | Optional. The description of the role assignment. |
| [`principalId`](#parameter-roleassignmentsprincipalid) | Yes | string | Required. The principal ID of the principal (user/group/identity) to assign the role to. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | No | string | Optional. The principal type of the assigned principal ID. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | Yes | string | Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead. |

### Parameter: `roleAssignments.condition`

Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container"

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Optional. Version of the condition.

- Required: No
- Type: string
- Allowed: `[2.0]`

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

Optional. The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

Optional. The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalId`

Required. The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.principalType`

Optional. The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed: `[Device, ForeignGroup, Group, ServicePrincipal, User]`

### Parameter: `roleAssignments.roleDefinitionIdOrName`

Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead.

- Required: Yes
- Type: string

### Parameter: `securityRules`

Array of Security Rules to deploy to the Network Security Group. When not provided, an NSG including only the built-in roles will be deployed.
- Required: No
- Type: array


| Name | Required | Type | Description |
| :-- | :-- | :--| :-- |
| [`access`](#parameter-securityrulesaccess) | Yes | string | Required. Whether network traffic is allowed or denied. |
| [`description`](#parameter-securityrulesdescription) | No | string | Optional. A description for this rule. |
| [`destination`](#parameter-securityrulesdestination) | Yes | array | Required. The destination can be one or more CIDR, IP ranges or Application Security Group resource Ids. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. |
| [`destinationPort`](#parameter-securityrulesdestinationport) | Yes | array | Required. One or more destination ports or ranges. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports. |
| [`direction`](#parameter-securityrulesdirection) | Yes | string | Required. The direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic. |
| [`name`](#parameter-securityrulesname) | Yes | string | Required. The name of the security rule. |
| [`priority`](#parameter-securityrulespriority) | Yes | int | Required. The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule. |
| [`protocol`](#parameter-securityrulesprotocol) | Yes | string | Required. Network protocol this rule applies to. |
| [`source`](#parameter-securityrulessource) | Yes | array | Required. The source can be one or more CIDR, IP ranges or Application Security Group resource Ids. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. |
| [`sourcePort`](#parameter-securityrulessourceport) | Yes | array | Required. One or more source ports or ranges. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports. |

### Parameter: `securityRules.access`

Required. Whether network traffic is allowed or denied.

- Required: Yes
- Type: string
- Allowed: `[Allow, Deny]`

### Parameter: `securityRules.description`

Optional. A description for this rule.

- Required: No
- Type: string

### Parameter: `securityRules.destination`

Required. The destination can be one or more CIDR, IP ranges or Application Security Group resource Ids. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used.

- Required: Yes
- Type: array

### Parameter: `securityRules.destinationPort`

Required. One or more destination ports or ranges. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.

- Required: Yes
- Type: array

### Parameter: `securityRules.direction`

Required. The direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic.

- Required: Yes
- Type: string
- Allowed: `[Inbound, Outbound]`

### Parameter: `securityRules.name`

Required. The name of the security rule.

- Required: Yes
- Type: string

### Parameter: `securityRules.priority`

Required. The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.

- Required: Yes
- Type: int

### Parameter: `securityRules.protocol`

Required. Network protocol this rule applies to.

- Required: Yes
- Type: string
- Allowed: `[*, Ah, Esp, Icmp, Tcp, Udp]`

### Parameter: `securityRules.source`

Required. The source can be one or more CIDR, IP ranges or Application Security Group resource Ids. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used.

- Required: Yes
- Type: array

### Parameter: `securityRules.sourcePort`

Required. One or more source ports or ranges. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.

- Required: Yes
- Type: array

### Parameter: `tags`

Tags of the NSG resource.
- Required: No
- Type: object


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the network security group. |
| `resourceGroupName` | string | The resource group the network security group was deployed into. |
| `resourceId` | string | The resource ID of the network security group. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other CARML modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/public:avm/res/network/network-security-group:0.1.2` | Remote reference |

