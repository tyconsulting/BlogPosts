param location string
param utcValue string = utcNow()
param roleName string
param subscriptionId string
param roleExists bool
param uamiId string
param storageAccountName string
param storageAccountId string
param storageAccountApiVersion string

resource role_def_scope_update_script 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (roleExists == true) {
  name: 'roleDefinitionUpdate'
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
    arguments: '-roleName \'${roleName}\' -subId \'${subscriptionId}\''
    scriptContent: '''
    param($roleName, $subId)
    $roleScopeUpdated = $false
    $role = Get-AzRoleDefinition -Name $roleName
    if ($role) {
      if ($role.IsCustom)
      {
        if ($role.AssignableScopes -inotcontains "/subscriptions/$subid") {
          $newScope = $role.AssignableScopes
          $newScope += "/subscriptions/$subId"
          $strNewScope = $newScope -join ","
          $role.AssignableScopes.Add("/subscriptions/$subId")
          set-AzRoleDefinition -Role $role
          $roleScopeUpdated = $true
          $output = "Role assignable scope updated. New scope: $strNewscope"
        } else {
          $output = "subscription $subId is already included in the role assignable scope"
        }
      } else {
        $output = "The role '$roleName' is not a custom role."
      }
    } else {
      $output = "Cannot find the role definition for '$roleName'."
    }
    Write-Output $output
    $DeploymentScriptsOutputs = @{}
    $DeploymentScriptOutputs['roleScopeUpdated'] = $roleScopeUpdated
    $DeploymentScriptOutputs['outputText'] = $output
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output roleScopeUpdated bool = roleExists ? role_def_scope_update_script.properties.outputs.roleScopeUpdated : false
output outputText string = roleExists ? role_def_scope_update_script.properties.outputs.outputText : 'Role definition update not required.'
