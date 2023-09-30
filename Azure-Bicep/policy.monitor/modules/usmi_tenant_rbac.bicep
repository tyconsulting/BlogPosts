targetScope = 'tenant'

@description('Required. Subscription Id for the User Assigned Managed Identity.')
param subscriptionId string

@description('Required. Resource Group name for the User Assigned Managed Identity.')
param resourceGroupName string

@description('Required. Role Definition Id.')
param roleDefinitionId string

@description('Required. User Assigned Managed Identity Name.')
param managedIdentityName string

// ---Lookup User Assigned Managed Identity---
resource usmi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
  scope: resourceGroup(subscriptionId, resourceGroupName)
}

// ---Role Assignment---
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(tenant().tenantId, subscriptionId, resourceGroupName, managedIdentityName, roleDefinitionId)
  properties: {
    principalId: usmi.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}
