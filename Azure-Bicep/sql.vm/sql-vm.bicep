@description('Azure location where the Azure SQL Virtual Machine cluster will be created')
param location string = resourceGroup().location

@description('enable Accelerated Networking on Azure SQL Virtual Machines')
param enableAcceleratedNetworking bool

@description('Specify the resourc egroup for virtual network')
param vnetResourceGroup string

@description('Specify the virtual network for Listener IP Address')
param vnetName string

@description('Specify the subnet under Vnet for Listener IP address')
param subnetName string

@description('Specify number of VM instances to be created')
param VirtualMachineCount int = 2

@description('Virtual Machine name prefix. A sequence number will be appended to create unique names')
param virtualMachineNamePrefix string

@description('Size for the Azure Virtual Machines')
param virtualMachineSize string

@description('Azure SQL Virtual Machines OS Disk type')
param osDiskType string 

@description('data disk configurations for the Azure Virtual Machines')
param dataDisks array = [
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 64
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 64
  }
  {
    createOption: 'empty'
    caching: 'None'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'None'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'None'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 128
  }
]

@description('Select the version of SQL Server Image type')
@allowed([
  'SQL2017-WS2016'
  'SQL2016SP2-WS2016'
  'SQL2019-WS2019'
])
param sqlServerImageType string

@description('SQL Server Image SKU. Choose between Developer and Enterprise')
@allowed([
  'Developer'
  'Enterprise'
])
param sqlImageSku string

@description('Domain NetBiosName plus User name of a domain user with sufficient rights to perform domain join operation. E.g. domain\\username')
param domainJoinUserName string

@description('Domain join user password')
param domainJoinUserPassword string

@description('Domain FQDN where the virtual machine will be joined')
param domainFQDN string

@description('Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) & NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx')
param domainJoinOptions int = 3

@description('Specifies an organizational unit (OU) for the computer account. Enter the full distinguished name of the OU in quotation marks. Example: "OU=testOU; DC=domain; DC=Domain; DC=com"')
param ouPath string = ''

@description('local administrator user name for the Azure SQL Virtual Machines')
param adminUsername string

@description('local administrator password for the Azure SQL Virtual Machines')
@secure()
param adminPassword string

@description('SQL server connectivity option (LOCAL, PRIVATE, PUBLIC)')
@allowed([
  'LOCAL'
  'PRIVATE'
  'PUBLIC'
])
param sqlConnectivityType string

@description('SQL server port')
param sqlPortNumber int = 1433

@description('SQL server workload type (DW, GENERAL, OLTP)')
@allowed([
  'DW'
  'GENERAL'
  'OLTP'
])
param sqlStorageWorkloadType string = 'OLTP'

@description('SQL server license type (AHUB, PAYG, DR)')
@allowed([
  'AHUB'
  'PAYG'
  'DR'
])
param sqlServerLicenseType string

@description('Enable or disable EKM provider for Azure Key Vault.')
param enableAkvEkm bool

@description('Azure Key Vault name (only required when enableAkvEkm is set to true).')
param ekmAkvName string = ''

@description('name of the sql credential created for Azure Key Vault EKM provider (only required when enableAkvEkm is set to true).')
param sqlAkvCredentialName string = 'sysadmin_ekm_cred'

@description('Azure service principal Application Id for accessing the EKM Azure Key Vault (only required when enableAkvEkm is set to true).')
param sqlAkvPrincipalName string = ''

@description('Azure service principal secret for accessing the EKM Azure Key Vault (only required when enableAkvEkm is set to true).')
@secure()
param sqlAkvPrincipalSecret string

@description('Default path for SQL data files.')
param dataPath string = 'F:\\SQLData'

@description('Logical Disk Numbers (LUN) for SQL data disks.')
param dataDisksLUNs array = [
  0
  1
]

@description('Default path for SQL log files.')
param logPath string = 'G:\\SQLLog'

@description('Logical Disk Numbers (LUN) for SQL log disks.')
param logDisksLUNs array = [
  2
  3
]

@description('Default path for SQL Temp DB files.')
param tempDBPath string = 'H:\\SQLTemp'

@description('Logical Disk Numbers (LUN) for SQL Temp DB disks.')
param tempDBDisksLUNs array = [
  4
  5
]

@description('(Optional) Create SQL Server sysadmin login user name')
param sqlAuthUpdateUserName string = ''

@description('(Optional) Create SQL Server sysadmin login password')
param sqlAuthUpdatePassword string = ''

@description('Enable or disable SQL server auto backup.')
param enableAutoBackup bool = false

@description('Enable or disable encryption for SQL server auto backup.')
param enableAutoBackupEncryption bool = false

@description('SQL backup retention period. 1-30 days')
param autoBackupRetentionPeriod int = 30

@description('name of the storage account used for SQL auto backup')
param autoBackupStorageAccountName string = ''

@description('Resource group for the storage account used for SQL Auto Backup')
param autoBackupStorageAccountResourceGroup string = resourceGroup().name

@description('password for SQL backup encryption. Required when \'enableAutoBackupEncryption\' is set to \'true\'.')
param autoBackupEncryptionPassword string = ''

@description('Include or exclude system databases from SQL server auto backup.')
param autoBackupSystemDbs bool = true

@description('SQL server auto backup schedule type - \'Manual\' or \'Automated\'.')
@allowed([
  'Manual'
  'Automated'
])
param autoBackupScheduleType string = 'Automated'

@description('SQL server auto backup full backup frequency - \'Daily\' or \'Weekly\'. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is \'Daily\'.')
@allowed([
  'Daily'
  'Weekly'
])
param autoBackupFullBackupFrequency string = 'Daily'

@description('SQL server auto backup full backup start time - 0-23 hours. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is 23.')
param autoBackupFullBackupStartTime int = 23

@description('SQL server auto backup full backup allowed duration - 1-23 hours. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is 2.')
param autoBackupFullBackupWindowHours int = 2

@description('SQL server auto backup log backup frequency - 5-60 minutes. Required parameter when \'autoBackupScheduleType\' is set to \'Manual\'. Default value is 60.')
param autoBackupLogBackupFrequency int = 60

@description('Enable or disable R services (SQL 2016 onwards).')
param rServicesEnabled bool = false

@description('Name of the SQL Always-On cluster name. Only required when deploying a SQL cluster. Only required when deploying a SQL cluster.')
param sqlVmGroupName string = ''

@description('The name of the SQL cluster witness storage account. Only required when deploying a SQL cluster.')
param clusterWitnessStorageAccountName string = ''

@description('Account name used for creating SQL cluster (at minimum needs permission to \'Create Computer Objects\' in domain). Only required when deploying a SQL cluster.')
param sqlClusterBootstrapAccount string = ''

@description('Account name used for operating cluster i.e. will be part of administrators group on all the participating virtual machines in the cluster. Only required when deploying a SQL cluster.')
param sqlClusterOperatorAccount string = ''

@description('Account name under which SQL service will run on all participating SQL virtual machines in the cluster. Only required when deploying a SQL cluster.')
param sqlServiceAccount string = ''

@description('password for the cluster bootstrap account. Only required when deploying a SQL cluster.')
@secure()
param sqlClusterBootstrapAccountPassword string = ''

@description('password for the cluster operator account. Only required when deploying a SQL cluster.')
@secure()
param sqlClusterOperatorAccountPassword string = ''

@description('password for the sql service account. Only required when deploying a SQL cluster.')
@secure()
param sqlServiceAccountPassword string = ''

@description('Specify the name of SQL Availability Group for which listener is being created. Only required when deploying a SQL cluster.')
param availabilityGroupName string = ''

@description('Specify the AG replica configuration. Only required when deploying a SQL cluster.')
param AGReplica array = [
  {
    commit: 'Synchronous_Commit'
    failover: 'Automatic'
    readableSecondary: 'no'
    role: 'Primary'
    sqlVMNo: 1
  }
  {
    commit: 'Asynchronous_Commit'
    failover: 'Manual'
    readableSecondary: 'no'
    role: 'Secondary'
    sqlVMNo: 2
  }
]

@description('Specify a name for the listener for SQL Availability Group. Only required when deploying a SQL cluster.')
param Listener string = 'aglistener'

@description('Specify the port for listener')
param ListenerPort int = 1433

@description('Specify the available private IP address for the listener from the subnet the existing Vms are part of. Only required when deploying a SQL cluster.')
param ListenerIp string = ''

@description('Name of internal load balancer for the AG listener.')
param loadBalancerName string = ''

@description('SKU for internal load balancer for the AG listener. Choose Standard Sku if the VMs are not in an availability set. Only required when deploying a SQL cluster.')
param loadBalancerSku string = 'Standard'

@description('The Load Balancer Private IP allocation method. - Static or Dynamic. Only required when deploying a SQL cluster.')
param loadBalancerPrivateIPAllocationMethod string = 'Dynamic'

@description('Specify the load balancer port number (e.g. 59999). Only required when deploying a SQL cluster.')
param ProbePort int = 59999

var tenantId = subscription().tenantId
var VMNames = [for i in range(1, VirtualMachineCount): '${virtualMachineNamePrefix}-${i}']
var AGReplica_var = [for item in AGReplica: {
  commit: item.commit
  failover: item.failover
  readableSecondary: item.readableSecondary
  role: item.role
  sqlVirtualMachineName: '${virtualMachineNamePrefix}-${item.sqlVMNo}'
}]

resource ekm_kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' = if (enableAkvEkm) {
  name : ekmAkvName
  location : location
  properties: {
    tenantId: tenantId
    accessPolicies : [
      {
        tenantId : tenantId
        objectId : sqlAkvPrincipalName
        permissions : {
          keys : [
            'get'
            'list'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
    sku : {
      family : 'A'
      name : 'standard'
    }
  }
}

module witness_storage_account './modules/storage-account.bicep' = if (!empty(sqlVmGroupName)) {
  name: 'witnessStorageAccount'
  params: {
    location: location
    name: clusterWitnessStorageAccountName
  }
}

module backup_storage_account './modules/storage-account.bicep' = if (enableAutoBackup) {
  name: 'backupStorageAccount'
  params: {
    location: location
    name: autoBackupStorageAccountName
  }
}

module sql_group './modules/sql-group.bicep' = if (!empty(sqlVmGroupName)) {
  name: 'sqlVMGroup'
  params: {
    location: location
    sqlImageSku: sqlImageSku
    sqlServerImageType: sqlServerImageType
    domainFQDN: domainFQDN
    ouPath: ouPath
    sqlVmGroupName: sqlVmGroupName
    sqlClusterBootstrapAccount: sqlClusterBootstrapAccount
    sqlClusterOperatorAccount: sqlClusterOperatorAccount
    sqlServiceAccount: sqlServiceAccount
    storageAccountName: clusterWitnessStorageAccountName
  }
  dependsOn: [
    witness_storage_account
  ]
}

@batchSize(1)
module sql_vm './modules/sql-vm.bicep' = [for (vm, i) in VMNames: {
  name: 'sqlVM-${vm}'
  params: {
    location: location
    enableAcceleratedNetworking: enableAcceleratedNetworking
    vnetResourceGroup: vnetResourceGroup
    vnetName: vnetName
    subnetName: subnetName
    virtualMachineName: vm
    AvailabilityZone: split(string(((i % 3) + 1)), ',')
    virtualMachineSize: virtualMachineSize
    osDiskType: osDiskType
    dataDisks: dataDisks
    sqlServerImageType: sqlServerImageType
    sqlImageSku: sqlImageSku
    domainJoinUserName: domainJoinUserName
    domainJoinUserPassword: domainJoinUserPassword
    domainFQDN: domainFQDN
    domainJoinOptions: domainJoinOptions
    ouPath: ouPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    sqlConnectivityType: sqlConnectivityType
    sqlPortNumber: sqlPortNumber
    sqlStorageWorkloadType: sqlStorageWorkloadType
    sqlServerLicenseType: sqlServerLicenseType
    enableAkvEkm: enableAkvEkm
    sqlAkvUrl: enableAkvEkm ? ekm_kv.properties.vaultUri : ''
    sqlAkvCredentialName: sqlAkvCredentialName
    sqlAkvPrincipalName: sqlAkvPrincipalName
    sqlAkvPrincipalSecret: sqlAkvPrincipalSecret
    dataPath: dataPath
    dataDisksLUNs: dataDisksLUNs
    logPath: logPath
    logDisksLUNs: logDisksLUNs
    tempDBPath: tempDBPath
    tempDBDisksLUNs: tempDBDisksLUNs
    sqlAuthUpdateUserName: sqlAuthUpdateUserName
    sqlAuthUpdatePassword: sqlAuthUpdatePassword
    enableAutoBackup: enableAutoBackup
    enableAutoBackupEncryption: enableAutoBackupEncryption
    autoBackupRetentionPeriod: autoBackupRetentionPeriod
    autoBackupStorageAccountName: backup_storage_account.outputs.name
    autoBackupStorageAccountResourceGroup: autoBackupStorageAccountResourceGroup
    autoBackupEncryptionPassword: autoBackupEncryptionPassword
    autoBackupSystemDbs: autoBackupSystemDbs
    autoBackupScheduleType: autoBackupScheduleType
    autoBackupFullBackupFrequency: autoBackupFullBackupFrequency
    autoBackupFullBackupStartTime: autoBackupFullBackupStartTime
    autoBackupFullBackupWindowHours: autoBackupFullBackupWindowHours
    autoBackupLogBackupFrequency: autoBackupLogBackupFrequency
    rServicesEnabled: rServicesEnabled
    sqlVmGroupName: sqlVmGroupName
    sqlClusterBootstrapAccountPassword: sqlClusterBootstrapAccountPassword
    sqlClusterOperatorAccountPassword: sqlClusterOperatorAccountPassword
    sqlServiceAccountPassword: sqlServiceAccountPassword
  }
  dependsOn: [
    backup_storage_account
  ]
}]

module sql_listener './modules/sql-listener.bicep' = if (!empty(sqlVmGroupName)) {
  name: 'sqlListener'
  params: {
    location: location
    existingFailoverClusterName: sqlVmGroupName
    availabilityGroupName: availabilityGroupName
    SQLVMNames: VMNames
    Listener: Listener
    ListenerPort: ListenerPort
    ListenerIp: ListenerIp
    vnetResourceGroup: vnetResourceGroup
    vnetName: vnetName
    subnetName: subnetName
    loadBalancerName: loadBalancerName
    loadBalancerSku: loadBalancerSku
    loadBalancerPrivateIPAllocationMethod: loadBalancerPrivateIPAllocationMethod
    ProbePort: ProbePort
    AGReplica: AGReplica_var
  }
  dependsOn: [
    sql_group
    sql_vm
  ]
}

output sql_group_id string = !empty(sqlVmGroupName)? sql_group.outputs.id : ''
output sql_listener_id string = !empty(sqlVmGroupName)? sql_listener.outputs.listener_id : ''
output load_balancer_id string = !empty(sqlVmGroupName)? sql_listener.outputs.load_balancer_id : ''
output witness_storage_account_id string = !empty(sqlVmGroupName)? witness_storage_account.outputs.id : ''
output backup_storage_account_id string = enableAutoBackup ? backup_storage_account.outputs.id : ''
output ekm_kv_id string = enableAkvEkm ? ekm_kv.id : ''
output vm_names array = VMNames
