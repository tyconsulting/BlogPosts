//scope
targetScope = 'subscription'
//param uamiId string
param location string = 'australia east'
param vnetRG string
param vnetName string
param subnetName string
param ipIndex int = 3

var rgName = 'rg-deployment-script'
var subId = subscription().subscriptionId
var subnetId = 'subscriptions/${subId}/resourceGroups/${vnetRG}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${subnetName}'
var subnetAddressPrefix = reference(subnetId, '2020-07-01', 'Full').properties.addressPrefix
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

module azcidrhost_deployment_script './azcidrhost-function.bicep' = {
  name: 'azcidrhost'
  scope: resourceGroup(rg.name)
  params: {
    //uamiId: uamiId
    location: location
    addressPrefix: subnetAddressPrefix
    ipIndex: ipIndex
    storageAccountName: storage_account.outputs.name
    storageAccountId: storage_account.outputs.id
    storageAccountApiVersion: storage_account.outputs.apiVersion
  }
}

output SelectedIP string = azcidrhost_deployment_script.outputs.SelectedIP
output SubnetSize int = azcidrhost_deployment_script.outputs.SubnetSize
output GatewayIP string = azcidrhost_deployment_script.outputs.GatewayIP
output DNSIP1 string = azcidrhost_deployment_script.outputs.DNSIP1
output DNSIP2 string = azcidrhost_deployment_script.outputs.DNSIP2
output FirstUsableIP string = azcidrhost_deployment_script.outputs.FirstUsableIP
output LastUsableIP string = azcidrhost_deployment_script.outputs.LastUsableIP

output subnetId string = subnetId
output subnetAddressPrefix string = subnetAddressPrefix
