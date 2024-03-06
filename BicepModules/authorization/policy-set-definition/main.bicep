metadata name = 'Policy Set Definitions (Initiatives) (All scopes)'
metadata description = 'This module deploys one or more Policy Set Definition(s) (Initiative) at a Management Group or Subscription scope.'
metadata owner = 'Tao Yang'

targetScope = 'managementGroup'

@sys.description('Required. Policy Set Definitions.')
param policySetDefinitions policySetDefinitionType

@sys.description('Optional. The group ID of the Management Group (Scope). If not provided, will use the current scope for deployment.')
param managementGroupId string = managementGroup().name

@sys.description('Optional. The subscription ID of the subscription (Scope). Cannot be used with managementGroupId.')
param subscriptionId string = ''

module policySetDefinition_mg 'management-group/main.bicep' = if (empty(subscriptionId)) {
  name: '${uniqueString(deployment().name, managementGroupId)}-PolicySetDefinition-MG-Module'
  scope: managementGroup(managementGroupId)
  params: {
    policySetDefinitions: policySetDefinitions
  }
}

module policySetDefinition_sub 'subscription/main.bicep' = if (!empty(subscriptionId)) {
  name: '${uniqueString(deployment().name, subscriptionId)}-PolicySetDefinition-Sub-Module'
  scope: subscription(subscriptionId)
  params: {
    policySetDefinitions: policySetDefinitions
  }
}

@sys.description('Deployed policy set definitions.')
output policySetDefinitions array = empty(subscriptionId) ? policySetDefinition_mg.outputs.policySetDefinitions : policySetDefinition_sub.outputs.policySetDefinitions

// =============== //
//   Definitions   //
// =============== //

type policyDefinitionsType = {

  @sys.description('Optional. The name of the groups that this policy definition reference belongs to.')
  groupNames: array?

  @sys.description('Optional. The parameter values for the referenced policy rule. The keys are the parameter names.')
  parameters: object?

  @sys.description('Required. The ID of the policy definition or policy set definition.')
  policyDefinitionId: string

  @sys.description('Optional. A unique id (within the policy set definition) for this policy definition reference.')
  policyDefinitionReferenceId: string?
}[]

type policyDefinitionGroupsType = {
  @sys.description('Required. The name of the group.')
  name: string

  @sys.description('Optional. The display name of the group.')
  displayName: string?

  @sys.description('Optional. The description of the group.')
  description: string?

  @sys.description('Optional. the category of the group.')
  category: string?

  @sys.description('Optional. A resource ID of a resource that contains additional metadata about the group.')
  additionalMetadataId: string?
}[]?

type policySetDefinitionType = {
  @sys.description('Required. The name of the policy Set Definition (Initiative).')
  name: string

  @sys.description('Optional. The display name of the Set Definition (Initiative). Maximum length is 128 characters.')
  displayName: string?

  @sys.description('Optional. The description of the Set Definition (Initiative).')
  description: string?

  @sys.description('Optional. The Set Definition (Initiative) metadata. Metadata is an open ended object and is typically a collection of key-value pairs.')
  metadata: object?

  @sys.description('Optional. The Set Definition (Initiative) parameters that can be used in policy definition references.')
  parameters: object?

  @sys.description('Optional. The metadata describing groups of policy definition references within the Policy Set Definition (Initiative).')
  policyDefinitionGroups: policyDefinitionGroupsType?

  @sys.description('Required. The array of Policy definitions object to include for this policy set. Each object must include the Policy definition ID, and optionally other properties like parameters.')
  policyDefinitions: policyDefinitionsType
}[]
