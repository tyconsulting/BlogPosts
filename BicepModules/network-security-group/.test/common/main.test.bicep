targetScope = 'subscription'

metadata name = 'Using large parameter set'
metadata description = 'This instance deploys the module with most of its features enabled.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-network.networksecuritygroups-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'nnsgcom'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '[[namePrefix]]'

var tags = {
  owner: 'Tao Yang'
}
// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-nestedDependencies'
  params: {
    managedIdentityName: 'dep-${namePrefix}-msi-${serviceShort}'
    applicationSecurityGroupName1: 'dep-${namePrefix}-asg1-${serviceShort}'
    applicationSecurityGroupName2: 'dep-${namePrefix}-asg2-${serviceShort}'
    applicationSecurityGroupName3: 'dep-${namePrefix}-asg3-${serviceShort}'
  }
}

// ============== //
// Test Execution //
// ============== //

module testDeployment '../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-test-${serviceShort}'
  params: {
    name: '${namePrefix}${serviceShort}001'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Reader'
        principalId: nestedDependencies.outputs.managedIdentityPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
    securityRules: [
      {
        name: 'Specific'
        access: 'Allow'
        description: 'Tests specific IPs and ports'
        destination: [ '*' ]
        destinationPort: [ '8080' ]
        direction: 'Inbound'
        priority: 200
        protocol: '*'
        source: [ '*' ]
        sourcePort: [ '*' ]
      }
      {
        name: 'Ranges'
        access: 'Allow'
        description: 'Tests Ranges'
        destination: [
          '10.2.0.0/16'
          '10.3.0.0/16'
        ]
        destinationPort: [
          '90'
          '91'
        ]
        direction: 'Inbound'
        priority: 210
        protocol: '*'
        source: [
          '10.0.0.0/16'
          '10.1.0.0/16'
        ]
        sourcePort: [
          '80'
          '81'
        ]
      }
      {
        name: 'Port_8082'
        access: 'Allow'
        description: 'Allow inbound access on TCP 8082'
        destination: [
          nestedDependencies.outputs.applicationSecurityGroup1ResourceId
          nestedDependencies.outputs.applicationSecurityGroup2ResourceId
        ]
        destinationPort: [ '8082' ]
        direction: 'Inbound'
        priority: 220
        protocol: '*'
        source: [
          nestedDependencies.outputs.applicationSecurityGroup3ResourceId
        ]
        sourcePort: [ '*' ]
      }
      {
        name: 'Port_8080'
        access: 'Deny'
        description: 'Deny outbound access on TCP 8080'
        destination: [
          nestedDependencies.outputs.applicationSecurityGroup1ResourceId
          nestedDependencies.outputs.applicationSecurityGroup2ResourceId
        ]
        destinationPort: [ '8080' ]
        direction: 'Outbound'
        priority: 210
        protocol: '*'
        source: [
          nestedDependencies.outputs.applicationSecurityGroup3ResourceId
        ]
        sourcePort: [ '*' ]
      }
    ]
    tags: tags
  }
}
