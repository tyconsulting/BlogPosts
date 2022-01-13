param location string = resourceGroup().location

@description('Azure SQL Virtual Machine name')
param virtualMachineName string

@description('SQL server license type')
@allowed([
  'AHUB'
  'PAYG'
  'DR'
])
param sqlServerLicenseType string = 'AHUB'

@description('Name of the SQL Always-On cluster name')
param sqlVmGroupName string

@description('password for the cluster bootstrap account')
@secure()
param sqlClusterBootstrapAccountPassword string

@description('password for the cluster operator account')
@secure()
param sqlClusterOperatorAccountPassword string

@description('password for the sql service account')
@secure()
param sqlServiceAccountPassword string

var sqlVmGroupId = (!empty(sqlVmGroupName)) ? resourceId('Microsoft.SqlVirtualMachine/sqlVirtualMachineGroups', sqlVmGroupName) : null

resource sql_vm 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2017-03-01-preview' = {
  name: virtualMachineName
  location: location
  properties: {
    virtualMachineResourceId: resourceId('Microsoft.Compute/virtualMachines', virtualMachineName)
    sqlManagement: 'Full'
    sqlServerLicenseType: sqlServerLicenseType
    sqlVirtualMachineGroupResourceId: sqlVmGroupId
    wsfcDomainCredentials: {
      clusterBootstrapAccountPassword: sqlClusterBootstrapAccountPassword
      clusterOperatorAccountPassword: sqlClusterOperatorAccountPassword
      sqlServiceAccountPassword: sqlServiceAccountPassword
    }
  }
}

output SQLVMId string = sql_vm.id
