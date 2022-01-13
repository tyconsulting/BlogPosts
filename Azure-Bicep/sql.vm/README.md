# Bicep Template for Azure SQL Virtual Machines and Clusters Sample Templates

## Introduction

Bicep modules and sample templates for deploying standalone Azure SQL VMs as well as Azure SQL VM Clusters.

This is a part of the blog post **[Azure SQL Virtual Machines - Sharing My Code and Experience](https://blog.tyang.org/2022/01/13/azure-sql-vm)**

## Bicep Files

### Template

* **[main.bicep](./main.bicep)**: Bicep template to deploy one or more Azure SQL VMs and all related resources either as standalone SQL servers (not clustered) or fully functioning clustered SQL VMs with SQL Always-On Availability Group (AOAG).

### Modules

The following modules are located in the **[modules](./modules)** folder.

* **[sql-vm.bicep](./modules/sql-vm.bicep)**: Bicep module for creating Azure Virtual Machine as we as Azure SQL VM ("Microsoft.SqlVirtualMachine/SqlVirtualMachines") resources. The SQL VM can be standalone or as a cluster node.
* **[sql-group.bicep](./modules/sql-group.bicep)**: Bicep module for creating Azure SQL VM Groups
* **[sql-listener.bicep](./modules/sql-listener.bicep)**: Bicep module for Azure SQL VM Availability Group listener and load balancer
* **[storage-account.bicep](./modules/sql-listener.bicep)**: Bicep module for Azure Storage Account (used to create storage accounts used for cluster witness and SQL auto backup)
* **[sql-cluster.join.bicep](./modules/sql-listener.bicep)**: Bicep module for joining *existing* SQL VMs to a cluster (not used in the Bicep template)

## Instructions

### Template Parameters

The following Parameters must be specified for the [main.bicep](./main.bicep) template:

| Name | Type | Mandatory | Default Value | Description |
| ---- | ---- | --------- | ------------- | ----------- |
| location| string | No | Resource Group location | Azure location where the Azure SQL Virtual Machine cluster will be created|
| enableAcceleratedNetworking | bool | Yes | N/A | enable Accelerated Networking on Azure SQL Virtual Machines |
| vnetResourceGroup | string | Yes | N/A | Specify the resource group for virtual network. |
| vnetName | string | Yes | N/A | Specify the virtual network for Listener IP Address |
| subnetName | string | Yes | N/A | Specify the subnet under Vnet for Listener IP address |
| VirtualMachineCount | int | No | 2 | Specify number of VM instances to be created |
| virtualMachineNamePrefix | string | Yes | N/A | Virtual Machine name prefix. A sequence number will be appended to create unique names |
| virtualMachineSize | string | Yes | N/A | Size for the Azure Virtual Machines |
| osDiskType | string | Yes | N/A | Azure SQL Virtual Machines OS Disk type |
| dataDisks | array | No | *refer to the **dataDisks** parameter in [main.bicep](./main.bicep) template* | data disk configurations for the Azure Virtual Machines |
| sqlServerImageType | string | Yes | N/A | Select the version of SQL Server Image type |
| sqlImageSku | String | Yes | N/A | SQL Server Image SKU. Choose between Developer and Enterprise |
| domainJoinUserName | sting | Yes | N/A | Domain NetBiosName plus User name of a domain user with sufficient rights to perform domain join operation. E.g. domain\username' |
| domainJoinUserPassword | secureString | Yes | N/A | Domain join user password |
| domainFQDN | string | Yes | N/A | Domain FQDN where the virtual machine will be joined |
| domainJoinOptions | int | No | 3 | Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) \& NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see [https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx](https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx) |
| ouPath | string | No | default OU for computers | Specifies an organizational unit (OU) for the computer account. Enter the full distinguished name of the OU in quotation marks. Example: "OU=testOU; DC=domain; DC=Domain; DC=com" |
| adminUsername | string | Yes | N/A | local administrator user name for the Azure SQL Virtual Machines |
| adminPassword | secureString | Yes | N/A | local administrator password for the Azure SQL Virtual Machines |
| sqlConnectivityType | string | Yes | N/A | SQL server connectivity option (LOCAL, PRIVATE, PUBLIC) |
| sqlPortNumber | int | No | 1433 | SQL server port |
| sqlStorageWorkloadType | string | No | OLTP | SQL server workload type (DW, GENERAL, OLTP) |
| sqlServerLicenseType | string | Yes | N/A | SQL server license type (AHUB, PAYG, DR) |
| enableAkvEkm | bool | Yes | N/A | Enable or disable EKM provider for Azure Key Vault |
| ekmAkvName | string | No | N/A | Azure Key Vault name (only required when enableAkvEkm is set to true). |
| sqlAkvCredentialName | string | No | sysadmin_ekm_cred | name of the sql credential created for Azure Key Vault EKM provider (only required when enableAkvEkm is set to true). |
| sqlAkvPrincipalName | string | No | N/A | Azure service principal Application Id for accessing the EKM Azure Key Vault (only required when enableAkvEkm is set to true). |
| sqlAkvPrincipalSecret | secureString | No | N/A | Azure service principal secret for accessing the EKM Azure Key Vault (only required when enableAkvEkm is set to true). |
| dataPath | string | No | F:\SQLData | Default path for SQL data files. |
| dataDisksLUNs | array | No | [0, 1] | Logical Disk Numbers (LUN) for SQL data disks. |
| logPath | string | No | G:\SQLLog | Default path for SQL log files. |
| logDisksLUNs | array | No | [2, 3] | Logical Disk Numbers (LUN) for SQL log disks. |
| tempDBPath | string | No | H:\SQLTemp | Default path for SQL Temp DB files. |
| tempDBDisksLUNs | array | No | [4, 5] | Logical Disk Numbers (LUN) for SQL Temp DB disks. |
| sqlAuthUpdateUserName | string | No | N/A | (Optional) Create SQL Server sysadmin login user name |
| sqlAuthUpdatePassword | string | No | N/A | (Optional) Create SQL Server sysadmin login password |
| enableAutoBackup | bool | No | false | Enable or disable SQL server auto backup. |
| enableAutoBackupEncryption | bool | No | false | Enable or disable encryption for SQL server auto backup. |
| autoBackupRetentionPeriod | int | No | 30 | SQL backup retention period. 1-30 days |
| autoBackupStorageAccountName | string | No | N/A | name of the storage account used for SQL auto backup |
| autoBackupStorageAccountResourceGroup | string | No | same resource group where the Azure SQL VMs are deployed to | Resource group for the storage account used for SQL Auto Backup' |
| autoBackupEncryptionPassword | string | No | N/A | password for SQL backup encryption. Required when 'enableAutoBackupEncryption' is set to 'true'. |
| autoBackupSystemDbs | bool | No | true | Include or exclude system databases from SQL server auto backup. |
| autoBackupScheduleType | string | No | Automated | SQL server auto backup schedule type - 'Manual' or 'Automated'. |
| autoBackupFullBackupFrequency | string | No | Daily | SQL server auto backup full backup frequency - 'Daily' or 'Weekly'. Required parameter when 'autoBackupScheduleType' is set to 'Manual'. Default value is 'Daily'. |
| autoBackupFullBackupStartTime | int | No | 23 | SQL server auto backup full backup start time - 0-23 hours. Required parameter when 'autoBackupScheduleType' is set to 'Manual'. Default value is 23. |
| autoBackupFullBackupWindowHours | int | No | 2 | SQL server auto backup full backup allowed duration - 1-23 hours. Required parameter when 'autoBackupScheduleType' is set to 'Manual'. Default value is 2. |
| autoBackupLogBackupFrequency | int | No | 60 | SQL server auto backup log backup frequency - 5-60 minutes. Required parameter when 'autoBackupScheduleType' is set to 'Manual'. Default value is 60. |
| rServicesEnabled | bool | No | false | Enable or disable R services (SQL 2016 onwards). |
| sqlVmGroupName | string | No | N/A | Name of the SQL Always-On cluster name. Only required when deploying a SQL cluster. Only required when deploying a SQL cluster. |
| clusterWitnessStorageAccountName | string | No | N/A | The name of the SQL cluster witness storage account. Only required when deploying a SQL cluster. |
| sqlClusterBootstrapAccount | string | No | N/A | Account name used for creating SQL cluster (at minimum needs permission to 'Create Computer Objects' in domain). Only required when deploying a SQL cluster. |
| sqlClusterOperatorAccount | string | No | N/A | Account name used for operating cluster i.e. will be part of administrators group on all the participating virtual machines in the cluster. Only required when deploying a SQL cluster. |
| sqlServiceAccount | string | No | N/A | Account name under which SQL service will run on all participating SQL virtual machines in the cluster. Only required when deploying a SQL cluster. |
| sqlClusterBootstrapAccountPassword | secureString | No | N/A | password for the cluster bootstrap account. Only required when deploying a SQL cluster. |
| sqlClusterOperatorAccountPassword | secureString | No | N/A | password for the cluster operator account. Only required when deploying a SQL cluster. |
| sqlServiceAccountPassword | secureString | No | N/A | password for the sql service account. Only required when deploying a SQL cluster. |
| availabilityGroupName | string | No | N/A | Specify the name of SQL Availability Group for which listener is being created. Only required when deploying a SQL cluster. | 
| AGReplica | array | No | *refer to the **AGReplica** parameter in [main.bicep](./main.bicep) template* | Specify the AG replica configuration. Only required when deploying a SQL cluster. |
| Listener | string | No | aglistener | Specify a name for the listener for SQL Availability Group. Only required when deploying a SQL cluster. |
| ListenerPort | int | No | 1433 | Specify the port for listener |
| ListenerIp | string | No | N/A | Specify the available private IP address for the listener from the subnet the existing Vms are part of. Only required when deploying a SQL cluster. |
| loadBalancerName | string | No | N/A | Name of internal load balancer for the AG listener. |
| loadBalancerSku | string | No | Standard | SKU for internal load balancer for the AG listener. Choose Standard Sku if the VMs are not in an availability set. Only required when deploying a SQL cluster. |
| loadBalancerPrivateIPAllocationMethod | string | No | Dynamic | The Load Balancer Private IP allocation method. - Static or Dynamic. Only required when deploying a SQL cluster. |
| ProbePort | int | No | 59999 | Specify the load balancer port number (e.g. 59999). Only required when deploying a SQL cluster. |

**2 parameter file examples have been provided:**

* **[cluster.parameters.json](./cluster.parameters.json):** Parameter file for creating a 2-node SQL VM cluster with Always-On Availability Group. Azure Key Vault EKM provider and Automated Backup are also enabled.
* **[standalone.parameters.json](./standalone.parameters.json):** Parameter file for creating a single standalone SQL VM. Azure Key Vault EKM provider and Automated Backup are also enabled.

### Deploy SQL VM Cluster

```bash
rg="rg-sql-vm-1"

az group create --name $rg --location australiaeast

# what-if
az deployment group what-if --resource-group $rg --template-file main.bicep --parameters cluster.parameters.json

#deploy
az deployment group create --name 'sql-vm-cluster' --resource-group $rg --template-file main.bicep --parameters cluster.parameters.json --verbose
```

### Deploy Standalone SQL VM

```bash
rg="rg-sql-vm-1"

az group create --name $rg --location australiaeast

# what-if
az deployment group what-if --resource-group $rg --template-file main.bicep --parameters standalone.parameters.json

#deploy
az deployment group create --name 'sql-vm-standalone' --resource-group $rg --template-file main.bicep --parameters standalone.parameters.json --verbose
```

### Features Not Implemented

The following Azure SQL VM features are not implemented in this template:

* Automated Patching
* File Share Witness for SQL Cluster
