param location string
param utcValue string = utcNow()
param roleName string
param uamiId string
param storageAccountName string
param storageAccountId string
param storageAccountApiVersion string
resource role_def_discovery_script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'roleDefinitionDiscovery'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '3.0'
    timeout: 'PT10M'
    storageAccountSettings: {
      storageAccountName: storageAccountName
      storageAccountKey: listKeys(storageAccountId, storageAccountApiVersion).keys[0].value
    }
    arguments: '-roleName \'${roleName}\''
    scriptContent: '''
    param($roleName)
    $role = Get-AzRoleDefinition -Name $roleName
    if ($role) {
      $roleExists = $true
      $existingRoleId = $role.id
      $existingScopes = $role.AssignableScopes -join ','
    } else {
      $roleExists = $false
      $existingRoleId = 'null'
      $existingScope = 'null'
    }
    $DeploymentScriptsOutputs = @{}
    $DeploymentScriptOutputs['roleExists'] = $roleExists
    $DeploymentScriptOutputs['existingRoleId'] = $existingRoleId
    $DeploymentScriptOutputs['existingScopes'] = $existingScopes
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output roleExists bool = role_def_discovery_script.properties.outputs.roleExists
output existingRoleId string = role_def_discovery_script.properties.outputs.existingRoleId
output existingScopes string = role_def_discovery_script.properties.outputs.existingScopes
