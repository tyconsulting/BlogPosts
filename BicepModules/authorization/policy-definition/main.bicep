metadata name = 'Policy Definitions (All scopes)'
metadata description = 'This module deploys one or more Policy Definition(s) at a Management Group or Subscription scope.'
metadata owner = 'Tao Yang'

targetScope = 'managementGroup'

@sys.description('Required. Policy Definitions.')
param policyDefinitions policyDefinitionType

@sys.description('Optional. The group ID of the Management Group (Scope). If not provided, will use the current scope for deployment.')
param managementGroupId string = managementGroup().name

@sys.description('Optional. The subscription ID of the subscription (Scope). Cannot be used with managementGroupId.')
param subscriptionId string = ''

module policyDefinition_mg 'management-group/main.bicep' = if (empty(subscriptionId)) {
  name: '${uniqueString(deployment().name, managementGroupId)}-PolicyDefinition-MG-Module'
  scope: managementGroup(managementGroupId)
  params: {
    policyDefinitions: policyDefinitions
  }
}

module policyDefinition_sub 'subscription/main.bicep' = if (!empty(subscriptionId)) {
  name: '${uniqueString(deployment().name, subscriptionId)}-PolicyDefinition-Sub-Module'
  scope: subscription(subscriptionId)
  params: {
    policyDefinitions: policyDefinitions
  }
}

@sys.description('Deployed policy definitions.')
output policyDefinitions array = empty(subscriptionId) ? policyDefinition_mg.outputs.policyDefinitions : policyDefinition_sub.outputs.policyDefinitions

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
