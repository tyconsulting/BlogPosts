@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

@description('Required. The name of the Managed Identity to create.')
param managedIdentityName string

@description('Required. The name of the 1st Application Security Group to create.')
param applicationSecurityGroupName1 string

@description('Required. The name of the 2nd Application Security Group to create.')
param applicationSecurityGroupName2 string

@description('Required. The name of the 3rd Application Security Group to create.')
param applicationSecurityGroupName3 string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource applicationSecurityGroup1 'Microsoft.Network/applicationSecurityGroups@2023-04-01' = {
  name: applicationSecurityGroupName1
  location: location
}

resource applicationSecurityGroup2 'Microsoft.Network/applicationSecurityGroups@2023-04-01' = {
  name: applicationSecurityGroupName2
  location: location
}

resource applicationSecurityGroup3 'Microsoft.Network/applicationSecurityGroups@2023-04-01' = {
  name: applicationSecurityGroupName3
  location: location
}
@description('The principal ID of the created Managed Identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

@description('The resource ID of the 1st created Application Security Group.')
output applicationSecurityGroup1ResourceId string = applicationSecurityGroup1.id

@description('The resource ID of the2nd created Application Security Group.')
output applicationSecurityGroup2ResourceId string = applicationSecurityGroup2.id

@description('The resource ID of the 3rd created Application Security Group.')
output applicationSecurityGroup3ResourceId string = applicationSecurityGroup3.id
