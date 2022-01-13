param location string = resourceGroup().location

@description('enable Accelerated Networking on Azure SQL Virtual Machines')
param enableAcceleratedNetworking bool = true

@description('Resource Group for the VNet that the Azure SQL Virtual Machines are connected to')
param vnetResourceGroup string

@description('Name of the VNet that the Azure SQL Virtual Machines are connected to')
param vnetName string

@description('Name of the subnet that the Azure SQL Virtual Machines are connected to')
param subnetName string

@description('Azure SQL Virtual Machine name')
param virtualMachineName string

@description('Azure SQL Virtual Machine Availability Zone')
param AvailabilityZone array = [
  1
]

@description('Size for the Azure Virtual Machines')
param virtualMachineSize string

@description('Azure SQL Virtual Machines OS Disk type')
param osDiskType string = 'Premium_LRS'

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

@description('SQL Server Image SKU')
@allowed([
  'Developer'
  'Enterprise'
])
param sqlImageSku string

@description('Domain NetBiosName plus User name of a domain user with sufficient rights to perfom domain join operation. E.g. domain\\username')
param domainJoinUserName string

@description('Domain join user password')
@secure()
param domainJoinUserPassword string

@description('Domain FQDN where the virtual machine will be joined')
param domainFQDN string

@description('Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) & NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx')
param domainJoinOptions int = 3

@description('Specifies an organizational unit (OU) for the domain account. Enter the full distinguished name of the OU in quotation marks. Example: "OU=testOU; DC=domain; DC=Domain; DC=com"')
param ouPath string = ''

@description('local administrator user name for the Azure SQL Virtual Machines')
param adminUsername string

@description('local administrator password for the Azure SQL Virtual Machines')
@secure()
param adminPassword string

@description('SQL server connectivity option')
@allowed([
  'LOCAL'
  'PRIVATE'
  'PUBLIC'
])
param sqlConnectivityType string = 'PRIVATE'

@description('SQL server port')
param sqlPortNumber int = 1433

@description('SQL server workload type')
@allowed([
  'DW'
  'GENERAL'
  'OLTP'
])
param sqlStorageWorkloadType string = 'OLTP'

@description('SQL server license type')
@allowed([
  'AHUB'
  'PAYG'
  'DR'
])
param sqlServerLicenseType string = 'AHUB'

@description('Enable or disable EKM provider for Azure Key Vault.')
param enableAkvEkm bool = false

@description('Azure Key Vault URL (only required when enableAkvEkm is set to true).')
param sqlAkvUrl string = ''

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

@description('Name of the SQL Always-On cluster name. Only required when deploying a SQL cluster.')
param sqlVmGroupName string = ''

@description('password for the cluster bootstrap account. Only required when deploying a SQL cluster.')
@secure()
param sqlClusterBootstrapAccountPassword string = ''

@description('password for the cluster operator account. Only required when deploying a SQL cluster.')
@secure()
param sqlClusterOperatorAccountPassword string = ''

@description('password for the sql service account. Only required when deploying a SQL cluster.')
@secure()
param sqlServiceAccountPassword string = ''

resource nic 'Microsoft.Network/networkInterfaces@2019-07-01' = {
  name: 'nic-${virtualMachineName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
  dependsOn: []
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: virtualMachineName
  zones: AvailabilityZone
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: sqlServerImageType
        sku: sqlImageSku
        version: 'latest'
      }
      dataDisks: [for (item, j) in dataDisks: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        managedDisk: {
          storageAccountType: item.storageAccountType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'nic-${virtualMachineName}')
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    licenseType: 'Windows_Server'
  }
  dependsOn: [
    nic
  ]
}

resource vm_ext_join_domain 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = {
  name: '${virtualMachineName}/joindomain'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainFQDN
      User: domainJoinUserName
      Restart: 'true'
      Options: domainJoinOptions
      OUPath: ouPath
    }
    protectedSettings: {
      Password: domainJoinUserPassword
    }
  }
  dependsOn: [
    vm
  ]
}

resource sql_vm 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2017-03-01-preview' = {
  name: virtualMachineName
  location: location
  properties: {
    virtualMachineResourceId: resourceId('Microsoft.Compute/virtualMachines', virtualMachineName)
    sqlManagement: 'Full'
    sqlServerLicenseType: sqlServerLicenseType
    sqlVirtualMachineGroupResourceId: (!empty(sqlVmGroupName)) ? resourceId('Microsoft.SqlVirtualMachine/sqlVirtualMachineGroups', sqlVmGroupName) : null
    autoPatchingSettings: {
      enable: false
    }
    autoBackupSettings: {
      enable: enableAutoBackup
      retentionPeriod: ((enableAutoBackup == true) ? autoBackupRetentionPeriod : null)
      storageAccountUrl: ((enableAutoBackup == true) ? reference(resourceId(autoBackupStorageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', autoBackupStorageAccountName), '2018-07-01').primaryEndpoints.blob : null)
      storageAccessKey: ((enableAutoBackup == true) ? first(listKeys(resourceId(autoBackupStorageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', autoBackupStorageAccountName), '2018-07-01').keys).value : null)
      enableEncryption: ((enableAutoBackup == true) ? enableAutoBackupEncryption : null)
      password: (((enableAutoBackup == true) && (enableAutoBackupEncryption == true)) ? autoBackupEncryptionPassword : null)
      backupSystemDbs: ((enableAutoBackup == true) ? autoBackupSystemDbs : null)
      backupScheduleType: ((enableAutoBackup == true) ? autoBackupScheduleType : null)
      fullBackupFrequency: (((enableAutoBackup == true) && (autoBackupScheduleType == 'Manual')) ? autoBackupFullBackupFrequency : null)
      fullBackupStartTime: (((enableAutoBackup == true) && (autoBackupScheduleType == 'Manual')) ? autoBackupFullBackupStartTime : null)
      fullBackupWindowHours: (((enableAutoBackup == true) && (autoBackupScheduleType == 'Manual')) ? autoBackupFullBackupWindowHours : null)
      logBackupFrequency: (((enableAutoBackup == true) && (autoBackupScheduleType == 'Manual')) ? int(autoBackupLogBackupFrequency) : null)
    }
    keyVaultCredentialSettings: {
      azureKeyVaultUrl: ((enableAkvEkm == true) ? sqlAkvUrl : null)
      credentialName: ((enableAkvEkm == true) ? sqlAkvCredentialName : null)
      enable: enableAkvEkm
      servicePrincipalName: ((enableAkvEkm == true) ? sqlAkvPrincipalName : null)
      servicePrincipalSecret: ((enableAkvEkm == true) ? sqlAkvPrincipalSecret : null)
    }
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      storageWorkloadType: sqlStorageWorkloadType
      sqlDataSettings: {
        luns: dataDisksLUNs
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: logDisksLUNs
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        luns: tempDBDisksLUNs
        defaultFilePath: tempDBPath
      }
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType: sqlConnectivityType
        port: sqlPortNumber
        sqlAuthUpdateUserName: sqlAuthUpdateUserName
        sqlAuthUpdatePassword: sqlAuthUpdatePassword
      }
      additionalFeaturesServerConfigurations: {
        isRServicesEnabled: rServicesEnabled
      }
    }
    wsfcDomainCredentials: {
      clusterBootstrapAccountPassword: (!empty(sqlVmGroupName)) ? sqlClusterBootstrapAccountPassword: null
      clusterOperatorAccountPassword: (!empty(sqlVmGroupName)) ? sqlClusterOperatorAccountPassword: null
      sqlServiceAccountPassword: (!empty(sqlVmGroupName)) ? sqlServiceAccountPassword: null
    }
  }
  dependsOn: [
    vm
    vm_ext_join_domain
  ]
}

output VMAdminUsername string = adminUsername
output VMId string = vm.id
output SQLVMId string = sql_vm.id
output VMName string = vm.name
