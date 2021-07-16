//scope
targetScope = 'subscription'
//param uamiId string
param location string = 'australia east'
param vnetRG string
param vnetName string
param subnetName string
param vmIpIndexes string = '3,4'
param vmName1 string
param vmName2 string
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

module private_ip_deployment_script './azcidrhost-function.bicep' = {
  name: 'private_ip'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    addressPrefix: subnetAddressPrefix
    ipIndexes: vmIpIndexes
    storageAccountName: storage_account.outputs.name
    storageAccountId: storage_account.outputs.id
    storageAccountApiVersion: storage_account.outputs.apiVersion
  }
}

module ubuntu_vm_01 './vm-ubuntu.bicep' = {
  name: 'ubuntu01'
  scope: resourceGroup(rg.name)
  params: {
    adminUsername: vmAdminUserName
    adminPasswordOrKey: vmAdminPassword
    location: location
    vmName: vmName1
    privateIP: private_ip_deployment_script.outputs.SelectedIPs.IP3
    subnetId: subnetId
    authenticationType: 'password'
  }
}

module ubuntu_vm_02 './vm-ubuntu.bicep' = {
  name: 'ubuntu02'
  scope: resourceGroup(rg.name)
  params: {
    adminUsername: vmAdminUserName
    adminPasswordOrKey: vmAdminPassword
    location: location
    vmName: vmName2
    privateIP: private_ip_deployment_script.outputs.SelectedIPs.IP4
    subnetId: subnetId
    authenticationType: 'password'
  }
}

output SelectedIPs object = private_ip_deployment_script.outputs.SelectedIPs
output SubnetSize int = private_ip_deployment_script.outputs.SubnetSize
output GatewayIP string = private_ip_deployment_script.outputs.GatewayIP
output DNSIP1 string = private_ip_deployment_script.outputs.DNSIP1
output DNSIP2 string = private_ip_deployment_script.outputs.DNSIP2
output FirstUsableIP string = private_ip_deployment_script.outputs.FirstUsableIP
output LastUsableIP string = private_ip_deployment_script.outputs.LastUsableIP

output subnetId string = subnetId
output subnetAddressPrefix string = subnetAddressPrefix
//output vmPrivateIp string = ubuntu_vm.outputs.privateIPAddress
