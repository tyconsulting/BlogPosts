targetScope = 'subscription'

param roleName string
param roleDescription string
param roleId string
param roleExists bool

resource jedi_master_role_def 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = if (roleExists == false) {
  name: roleId
  properties: {
    roleName: roleName
    description: roleDescription
    assignableScopes: [
      subscription().id
    ]
    permissions: [
      {
        'actions': [
          'Microsoft.Authorization/*/read'
          'Microsoft.Authorization/policyAssignments/*'
          'Microsoft.Authorization/policyDefinitions/*'
          'Microsoft.Authorization/policySetDefinitions/*'
        ]
        'notActions': []
      }
    ]
  }
}

output newRoleId string = roleExists ? 'null' : jedi_master_role_def.name
