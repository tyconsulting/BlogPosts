param location string

@description('Select the version of SQL Server Image type')
@allowed([
  'SQL2017-WS2016'
  'SQL2016SP2-WS2016'
  'SQL2019-WS2019'
])
param sqlServerImageType string

@description('SQL Server Image SKU')
@allowed([
  'Developer'
  'Enterprise'
])
param sqlImageSku string

@description('Domain FQDN where the virtual machine will be joined')
param domainFQDN string

@description('Specifies an organizational unit (OU) for the domain account. Enter the full distinguished name of the OU in quotation marks. Example: "OU=testOU; DC=domain; DC=Domain; DC=com"')
param ouPath string = ''

@description('Name of the SQL Always-On cluster name.')
param sqlVmGroupName string

@description('Account name used for creating SQL cluster (at minimum needs permission to \'Create Computer Objects\' in domain).')
param sqlClusterBootstrapAccount string

@description('Account name used for operating cluster i.e. will be part of administrators group on all the participating virtual machines in the cluster.')
param sqlClusterOperatorAccount string

@description('Account name under which SQL service will run on all participating SQL virtual machines in the cluster.')
param sqlServiceAccount string


@description('The name of the SQL cluster witness storage account.')
param storageAccountName string

resource sql_vm_grp 'Microsoft.SqlVirtualMachine/sqlVirtualMachineGroups@2017-03-01-preview' = {
  name: sqlVmGroupName
  location: location
  properties: {
    sqlImageOffer: sqlServerImageType
    sqlImageSku: sqlImageSku
    wsfcDomainProfile: {
      domainFqdn: domainFQDN
      ouPath: ouPath
      clusterBootstrapAccount: sqlClusterBootstrapAccount
      clusterOperatorAccount: sqlClusterOperatorAccount
      sqlServiceAccount: sqlServiceAccount
      storageAccountUrl: reference(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-06-01').primaryEndpoints.blob
      storageAccountPrimaryKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-06-01').keys[0].value
    }
  }
}

output name string = sql_vm_grp.name
output id string = sql_vm_grp.id
