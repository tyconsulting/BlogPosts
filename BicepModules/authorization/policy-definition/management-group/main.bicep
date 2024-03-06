metadata name = 'Policy Definitions (Management Group scope)'
metadata description = 'This module deploys one or more Policy Definition(s) at a Management Group scope.'
metadata owner = 'Tao Yang'

targetScope = 'managementGroup'

@sys.description('Required. Policy Definitions.')
param policyDefinitions policyDefinitionType

@batchSize(15)
resource policies 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for definition in policyDefinitions: {
  name: definition.name
  properties: {
    policyType: 'Custom'
    mode: definition.mode
    displayName: contains(definition, 'displayName') ? definition.displayName : null
    description: contains(definition, 'description') ? definition.description : null
    metadata: contains(definition, 'metadata') ? definition.metadata : null
    parameters: contains(definition, 'parameters') ? definition.parameters : null
    policyRule: definition.policyRule
  }
}]

@sys.description('Deployed policy definitions.')
output policyDefinitions array = [for (definition, i) in policyDefinitions: {
  name: policies[i].name
  resourceId: policies[i].id
  roleDefinitionIds: (contains(policies[i].properties.policyRule.then, 'details') ? ((contains(policies[i].properties.policyRule.then.details, 'roleDefinitionIds') ? policies[i].properties.policyRule.then.details.roleDefinitionIds : [])) : [])
}]

// =============== //
//   Definitions   //
// =============== //

type policyDefinitionType = {

  @sys.description('Required. Specifies the name of the policy definition. Maximum length is 64 characters.')
  @maxLength(64)
  name: string

  @sys.description('Optional. The display name of the policy definition. Maximum length is 128 characters.')
  @maxLength(128)
  displayName: string?

  @sys.description('Optional. The policy definition description.')
  description: string?

  @sys.description('Required. The policy definition mode. Default is All, Some examples are All, Indexed, Microsoft.KeyVault.Data.')
  mode: ('All' | 'Indexed' | 'Microsoft.KeyVault.Data' | 'Microsoft.ContainerService.Data' | 'Microsoft.Kubernetes.Data' | 'Microsoft.Network.Data')

  @sys.description('Optional. The policy Definition metadata. Metadata is an open ended object and is typically a collection of key-value pairs.')
  metadata: {}?

  @sys.description('Optional. The policy definition parameters that can be used in policy definition references.')
  parameters: {}?

  @sys.description('Required. The Policy Rule details for the Policy Definition.')
  policyRule: {}
}[]
