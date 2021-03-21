//scope
targetScope = 'subscription'

param location string = 'australia east'
param uamiId string

var roleName = 'Jedi Master'
var roleDescription = 'May the force be with you'
var roleId = guid('customRole-jedi-master')
var rgName = 'rg-deployment-script'

//Resource group
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

//Storage account for deployment scripts
module storage_account './storage-account.bicep' = {
  name: 'deploymentScriptStorage'
  scope: resourceGroup(rg.name)
  params: {
    location: location
  }
}

module role_discovery './role-discovery.bicep' = {
  name: 'roleDefinitionDiscovery'
  scope: resourceGroup(rg.name)
  params: {
    uamiId: uamiId
    location: location
    roleName: roleName
    storageAccountName: storage_account.outputs.name
    storageAccountId: storage_account.outputs.id
    storageAccountApiVersion: storage_account.outputs.apiVersion
  }
}

module role_definition './role-definition.bicep' = {
  name: 'roleDefinitionDeployment'
  params: {
    roleName: roleName
    roleDescription: roleDescription
    roleId: roleId
    roleExists: role_discovery.outputs.roleExists
  }
}

module role_scope_update './role-scope-update.bicep' = {
  name: 'roleScopeUpdate'
  scope: resourceGroup(rg.name)
  params: {
    uamiId: uamiId
    location: location
    roleName: roleName
    subscriptionId: subscription().subscriptionId
    roleExists: role_discovery.outputs.roleExists
    storageAccountName: storage_account.outputs.name
    storageAccountId: storage_account.outputs.id
    storageAccountApiVersion: storage_account.outputs.apiVersion
  }
}

output roleExists bool = role_discovery.outputs.roleExists
output existingRoleId string = role_discovery.outputs.existingRoleId
output existingScopes string = role_discovery.outputs.existingScopes
output existingRoleScopeUpdated bool = role_scope_update.outputs.roleScopeUpdated
output existingRoleScopeUpdateMessage string = role_scope_update.outputs.outputText
output newRoleId string = role_definition.outputs.newRoleId
