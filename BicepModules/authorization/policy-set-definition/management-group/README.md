# Policy Set Definitions (Initiatives) (Management Group scope) `[Microsoft.Authorization/policySetDefinitions]`

This module deploys one or more Policy Set Definition(s) (Initiative) at a Management Group scope.

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
| [`policySetDefinitions`](#parameter-policysetdefinitions) | array | Policy Set Definitions. |

### Parameter: `policySetDefinitions`

Policy Set Definitions.

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-policysetdefinitionsname) | string | The name of the policy Set Definition (Initiative). |
| [`policyDefinitions`](#parameter-policysetdefinitionspolicydefinitions) | array | The array of Policy definitions object to include for this policy set. Each object must include the Policy definition ID, and optionally other properties like parameters. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-policysetdefinitionsdescription) | string | The description of the Set Definition (Initiative). |
| [`displayName`](#parameter-policysetdefinitionsdisplayname) | string | The display name of the Set Definition (Initiative). Maximum length is 128 characters. |
| [`metadata`](#parameter-policysetdefinitionsmetadata) | object | The Set Definition (Initiative) metadata. Metadata is an open ended object and is typically a collection of key-value pairs. |
| [`parameters`](#parameter-policysetdefinitionsparameters) | object | The Set Definition (Initiative) parameters that can be used in policy definition references. |
| [`policyDefinitionGroups`](#parameter-policysetdefinitionspolicydefinitiongroups) | array | The metadata describing groups of policy definition references within the Policy Set Definition (Initiative). |

### Parameter: `policySetDefinitions.name`

The name of the policy Set Definition (Initiative).

- Required: Yes
- Type: string

### Parameter: `policySetDefinitions.policyDefinitions`

The array of Policy definitions object to include for this policy set. Each object must include the Policy definition ID, and optionally other properties like parameters.

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`policyDefinitionId`](#parameter-policysetdefinitionspolicydefinitionspolicydefinitionid) | string | The ID of the policy definition or policy set definition. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`groupNames`](#parameter-policysetdefinitionspolicydefinitionsgroupnames) | array | The name of the groups that this policy definition reference belongs to. |
| [`parameters`](#parameter-policysetdefinitionspolicydefinitionsparameters) | object | The parameter values for the referenced policy rule. The keys are the parameter names. |
| [`policyDefinitionReferenceId`](#parameter-policysetdefinitionspolicydefinitionspolicydefinitionreferenceid) | string | A unique id (within the policy set definition) for this policy definition reference. |

### Parameter: `policySetDefinitions.policyDefinitions.policyDefinitionId`

The ID of the policy definition or policy set definition.

- Required: Yes
- Type: string

### Parameter: `policySetDefinitions.policyDefinitions.groupNames`

The name of the groups that this policy definition reference belongs to.

- Required: No
- Type: array

### Parameter: `policySetDefinitions.policyDefinitions.parameters`

The parameter values for the referenced policy rule. The keys are the parameter names.

- Required: No
- Type: object

### Parameter: `policySetDefinitions.policyDefinitions.policyDefinitionReferenceId`

A unique id (within the policy set definition) for this policy definition reference.

- Required: No
- Type: string

### Parameter: `policySetDefinitions.description`

The description of the Set Definition (Initiative).

- Required: No
- Type: string

### Parameter: `policySetDefinitions.displayName`

The display name of the Set Definition (Initiative). Maximum length is 128 characters.

- Required: No
- Type: string

### Parameter: `policySetDefinitions.metadata`

The Set Definition (Initiative) metadata. Metadata is an open ended object and is typically a collection of key-value pairs.

- Required: No
- Type: object

### Parameter: `policySetDefinitions.parameters`

The Set Definition (Initiative) parameters that can be used in policy definition references.

- Required: No
- Type: object

### Parameter: `policySetDefinitions.policyDefinitionGroups`

The metadata describing groups of policy definition references within the Policy Set Definition (Initiative).

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-policysetdefinitionspolicydefinitiongroupsname) | string | The name of the group. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`additionalMetadataId`](#parameter-policysetdefinitionspolicydefinitiongroupsadditionalmetadataid) | string | A resource ID of a resource that contains additional metadata about the group. |
| [`category`](#parameter-policysetdefinitionspolicydefinitiongroupscategory) | string | the category of the group. |
| [`description`](#parameter-policysetdefinitionspolicydefinitiongroupsdescription) | string | The description of the group. |
| [`displayName`](#parameter-policysetdefinitionspolicydefinitiongroupsdisplayname) | string | The display name of the group. |

### Parameter: `policySetDefinitions.policyDefinitionGroups.name`

The name of the group.

- Required: Yes
- Type: string

### Parameter: `policySetDefinitions.policyDefinitionGroups.additionalMetadataId`

A resource ID of a resource that contains additional metadata about the group.

- Required: No
- Type: string

### Parameter: `policySetDefinitions.policyDefinitionGroups.category`

the category of the group.

- Required: No
- Type: string

### Parameter: `policySetDefinitions.policyDefinitionGroups.description`

The description of the group.

- Required: No
- Type: string

### Parameter: `policySetDefinitions.policyDefinitionGroups.displayName`

The display name of the group.

- Required: No
- Type: string


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `policySetDefinitions` | array | Deployed policy definitions. |

## Cross-referenced modules

_None_
