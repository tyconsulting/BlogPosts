@description('Name of the Storage Account')
param storageAccountName string

@description('Location for all Resources.')
param location string = 'australiaeast'

@description('Tag values')
param tags object = {}

@description('The static privavte IP address for the blob private endpoint.')
param blobPrivateEndpointIP string

@description('The static privavte IP address for the dfs private endpoint.')
param dfsPrivateEndpointIP string

@description('Existing Subnet Resource ID to assign to the Private Endpoint.')
param subnetId string

var blobPrivateEndpointName = 'pe-${storageAccountName}-blob'
var blobPrivateEndpointNicName = 'nic-pe-${storageAccountName}-blob'
var dfsPrivateEndpointName = 'pe-${storageAccountName}-dfs'
var dfsPrivateEndpointNicName = 'nic-pe-${storageAccountName}-dfs'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob:  {
          enabled: true
        }
      }
      requireInfrastructureEncryption: true
    }
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    allowCrossTenantReplication: false
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
    isLocalUserEnabled: false
    isSftpEnabled: false
    supportsHttpsTrafficOnly: true
  }
}

resource blobPe 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: blobPrivateEndpointName
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: blobPrivateEndpointNicName
    ipConfigurations:  [
      {
        name: 'ipconfig1'
        properties: {
          groupId: 'blob'
          memberName: 'blob'
          privateIPAddress: blobPrivateEndpointIP
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: blobPrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource dfsPe 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: dfsPrivateEndpointName
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: dfsPrivateEndpointNicName
    ipConfigurations:  [
      {
        name: 'ipconfig1'
        properties: {
          groupId: 'dfs'
          memberName: 'dfs'
          privateIPAddress: dfsPrivateEndpointIP
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: dfsPrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'dfs'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}


output storageAccountResourceId string = storageAccount.id
output storageAccountIdentityPrincipalId string = storageAccount.identity.principalId
output blobPrivateEndpointName string = blobPrivateEndpointName
output blobPrivateEndpointResourceId string = blobPe.id
output dfsPrivateEndpointName string = dfsPrivateEndpointName
output dfsPrivateEndpointResourceId string = dfsPe.id
