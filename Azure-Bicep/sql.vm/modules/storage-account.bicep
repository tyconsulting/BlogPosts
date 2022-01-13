param location string
param name string
resource stg 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output name string = stg.name
output id string = stg.id
output apiVersion string = stg.apiVersion
