//scope
targetScope = 'subscription'
//param uamiId string
param location string = 'australia east'
param vnetRG string
param vnetName string
param subnetName string
param vmIpIndex int = 3
param vmName string
param vmAdminUserName string

@secure()
param vmAdminPassword string

var rgName = 'rg-vm-demo'
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

module ubuntu01_private_ip_deployment_script './azcidrhost-function.bicep' = {
  name: 'ubuntu01_private_ip'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    addressPrefix: subnetAddressPrefix
    ipIndex: vmIpIndex
    storageAccountName: storage_account.outputs.name
    storageAccountId: storage_account.outputs.id
    storageAccountApiVersion: storage_account.outputs.apiVersion
  }
}

module ubuntu_vm './vm-ubuntu.bicep' = {
  name: 'ubuntu01'
  scope: resourceGroup(rg.name)
  params: {
    adminUsername: vmAdminUserName
    adminPasswordOrKey: vmAdminPassword
    location: location
    vmName: vmName
    privateIP: ubuntu01_private_ip_deployment_script.outputs.SelectedIP
    subnetId: subnetId
    authenticationType: 'password'
  }
}

output SelectedIP string = ubuntu01_private_ip_deployment_script.outputs.SelectedIP
output SubnetSize int = ubuntu01_private_ip_deployment_script.outputs.SubnetSize
output GatewayIP string = ubuntu01_private_ip_deployment_script.outputs.GatewayIP
output DNSIP1 string = ubuntu01_private_ip_deployment_script.outputs.DNSIP1
output DNSIP2 string = ubuntu01_private_ip_deployment_script.outputs.DNSIP2
output FirstUsableIP string = ubuntu01_private_ip_deployment_script.outputs.FirstUsableIP
output LastUsableIP string = ubuntu01_private_ip_deployment_script.outputs.LastUsableIP

output subnetId string = subnetId
output subnetAddressPrefix string = subnetAddressPrefix
output vmPrivateIp string = ubuntu_vm.outputs.privateIPAddress
