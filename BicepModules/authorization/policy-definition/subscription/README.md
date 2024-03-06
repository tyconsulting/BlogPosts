# Policy Definitions (Subscription scope) `[Microsoft.Authorization/policyDefinitions]`

This module deploys one or more Policy Definition(s) at a Subscription scope.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)

## Resource Types

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`policyDefinitions`](#parameter-policydefinitions) | array | Policy Definitions. |

### Parameter: `policyDefinitions`

Policy Definitions.

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`mode`](#parameter-policydefinitionsmode) | string | The policy definition mode. Default is All, Some examples are All, Indexed, Microsoft.KeyVault.Data. |
| [`name`](#parameter-policydefinitionsname) | string | Specifies the name of the policy definition. Maximum length is 64 characters. |
| [`policyRule`](#parameter-policydefinitionspolicyrule) | object | The Policy Rule details for the Policy Definition. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-policydefinitionsdescription) | string | The policy definition description. |
| [`displayName`](#parameter-policydefinitionsdisplayname) | string | The display name of the policy definition. Maximum length is 128 characters. |
| [`metadata`](#parameter-policydefinitionsmetadata) | object | The policy Definition metadata. Metadata is an open ended object and is typically a collection of key-value pairs. |
| [`parameters`](#parameter-policydefinitionsparameters) | object | The policy definition parameters that can be used in policy definition references. |

### Parameter: `policyDefinitions.mode`

The policy definition mode. Default is All, Some examples are All, Indexed, Microsoft.KeyVault.Data.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'All'
    'Indexed'
    'Microsoft.ContainerService.Data'
    'Microsoft.KeyVault.Data'
    'Microsoft.Kubernetes.Data'
    'Microsoft.Network.Data'
  ]
  ```

### Parameter: `policyDefinitions.name`

Specifies the name of the policy definition. Maximum length is 64 characters.

- Required: Yes
- Type: string

### Parameter: `policyDefinitions.policyRule`

The Policy Rule details for the Policy Definition.

- Required: Yes
- Type: object

### Parameter: `policyDefinitions.description`

The policy definition description.

- Required: No
- Type: string

### Parameter: `policyDefinitions.displayName`

The display name of the policy definition. Maximum length is 128 characters.

- Required: No
- Type: string

### Parameter: `policyDefinitions.metadata`

The policy Definition metadata. Metadata is an open ended object and is typically a collection of key-value pairs.

- Required: No
- Type: object

### Parameter: `policyDefinitions.parameters`

The policy definition parameters that can be used in policy definition references.

- Required: No
- Type: object


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `policyDefinitions` | array | Deployed policy definitions. |

## Cross-referenced modules

_None_
