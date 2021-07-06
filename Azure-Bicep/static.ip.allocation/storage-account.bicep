param location string = resourceGroup().location
resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'sadscript${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output name string = stg.name
output id string = stg.id
output apiVersion string = stg.apiVersion
