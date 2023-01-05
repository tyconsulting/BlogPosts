@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tags')
param tags object = {}

@description('Existing Virtual Network name')
param existingVNETName string

@description('Existing Private Endpoint Subnet Name')
param privateEndpointSubnetName string

@description('Name of Azure Relay Namespace.')
param relayNamespaceName string

@description('The static privavte IP address for the private endpoint.')
param relayPrivateEndpointStaticPrivateIPAddress string

@description('Object Id of Azure Container Instance Service Principal. We have to grant this permission to create hybrid connections in the Azure Relay you specify. To get it: Get-AzADServicePrincipal -DisplayNameBeginsWith \'Azure Container Instance\'')
param azureContainerInstanceOID string

@description('Name of the subnet to use for cloud shell containers.')
param containerSubnetName string = 'CloudShell'

@description('Address space of the subnet to add for cloud shell. e.g. 10.0.1.0/26')
param containerSubnetAddressPrefix string

@description('Name of Cloud Shell Storage Account')
param cloudShellStorageAccountName string

@description('Name of the resource tag.')
param tagName object = {
  Environment: 'cloudshell'
}

var networkProfileName = 'aci-networkProfile-${location}'
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var networkRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
var privateDnsZoneName = ((toLower(environment().name) == 'azureusgovernment') ? 'privatelink.servicebus.usgovcloudapi.net' : 'privatelink.servicebus.windows.net')
var vnetResourceId = resourceId('Microsoft.Network/virtualNetworks', existingVNETName)
var relayPrivateEndpointName = 'pe-${relayNamespaceName}'
var relayPrivateEndpointCustomNetworkInterfaceName = 'nic-pe-${relayNamespaceName}'
resource existingVNET 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: existingVNETName

  resource privateEndpointSubnet 'subnets@2021-08-01' existing = {
    name: privateEndpointSubnetName
  }
}

//CloudShell Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: cloudShellStorageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_GZRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      requireInfrastructureEncryption: true
    }
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: containerSubnet.id
          action: 'Allow'
        }
      ]
      bypass: 'AzureServices'
    }
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true //required for CloudShell
    allowCrossTenantReplication: false
    publicNetworkAccess: 'Enabled' //required to be Enabled to leverage Service Endpoint
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: false
    isLocalUserEnabled: false
    isSftpEnabled: false
    supportsHttpsTrafficOnly: true
  }
}

//Cloudshell subnet
resource containerSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  parent: existingVNET
  name: containerSubnetName
  properties: {
    addressPrefix: containerSubnetAddressPrefix
    serviceEndpointPolicies: [
      {
        id: serviceEndpointPolicy.id
      }
    ]
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        locations: [
          location
        ]
      }
    ]
    delegations: [
      {
        name: 'CloudShellDelegation'
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
      }
    ]
  }
}
//Service endpoint policy
resource serviceEndpointPolicy 'Microsoft.network/ServiceEndpointPolicies@2022-07-01' = {
  name: 'CloudShellStorageServiceEndpointPolicy'
  location: location
  tags: tags
  properties: {
    serviceEndpointPolicyDefinitions: [
      {
        name: 'CloudShell.Storage'
        properties: {
          service: 'Microsoft.Storage'
          description: 'Allow Microsoft.Storage'
          serviceResources: [
            resourceGroup().id
          ]
        }
        type: 'Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions'
      }
    ]
  }
}
//network profile for container instance
resource networkProfile 'Microsoft.Network/networkProfiles@2021-08-01' = {
  name: networkProfileName
  tags: tagName
  location: location
  properties: {
    containerNetworkInterfaceConfigurations: [
      {
        name: 'eth-${containerSubnetName}'
        properties: {
          ipConfigurations: [
            {
              name: 'ipconfig-${containerSubnetName}'
              properties: {
                subnet: {
                  id: containerSubnet.id
                }
              }
            }
          ]
        }
      }
    ]
  }
}

//role assignments
resource networkProfile_roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: networkProfile
  name: guid(networkRoleDefinitionId, azureContainerInstanceOID, networkProfile.name)
  properties: {
    roleDefinitionId: networkRoleDefinitionId
    principalId: azureContainerInstanceOID
  }
}
resource roleAssignmentAciContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, resourceGroup().name, contributorRoleDefinitionId, azureContainerInstanceOID)
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: azureContainerInstanceOID
    principalType: 'ServicePrincipal'
  }
}

// Azure Relay
resource relayNamespace 'Microsoft.Relay/namespaces@2021-11-01' = {
  name: relayNamespaceName
  tags: tags
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource relayPE 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: relayPrivateEndpointName
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: relayPrivateEndpointCustomNetworkInterfaceName
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          groupId: 'namespace'
          memberName: 'namespace'
          privateIPAddress: relayPrivateEndpointStaticPrivateIPAddress
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: relayPrivateEndpointName
        properties: {
          privateLinkServiceId: relayNamespace.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
    subnet: {
      id: existingVNET::privateEndpointSubnet.id
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource privateDnsZoneARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: relayNamespaceName
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: first(first(relayPE.properties.customDnsConfigs).ipAddresses)
      }
    ]
  }
}

output vnetId string = vnetResourceId
output containerSubnetId string = containerSubnet.id
output relayNamespaceId string = relayNamespace.id
output storageAccountId string = storageAccount.id
