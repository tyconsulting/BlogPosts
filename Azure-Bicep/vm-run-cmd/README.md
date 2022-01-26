# Bicep Template for Azure VM Run Command

## Introduction

Bicep modules and sample templates for invoking VM Run Commands on Azure VMs.

This is a part of the blog post **[Azure Bicep Module for Virtual Machine Run Commands](https://blog.tyang.org/2022/01/26/azure-bicep-vm-run-cmd)**

## Bicep Files

### Sample Template

* **[windows.bicep](./sample/windows.bicep)**: Bicep template to invoke scripts and commands on 2 different Windows VMs in the same resource group

* **[linux.bicep](./sample/linux.bicep)**: Bicep template to invoke scripts and commands on 2 different Linux VMs in the same resource group

### Modules

The following modules are located in the **[modules](./modules)** folder.

* **[vm-run-cmd.bicep](./modules/vm-run-cmd.bicep)**: Bicep module for Azure VM Run Command (on existing VMs)

## Instructions

### Template Parameters

#### windows.bicep

The following Parameters must be specified for the [windows.bicep](./sample/windows.bicep) template:

| Name | Type | Mandatory | Default Value | Description |
| ---- | ---- | --------- | ------------- | ----------- |
| name | string | Yes | N/A | Run Command Name |
| vmName1 | string | Yes | N/A | Virtual Machine #1 name |
| vmName2 | string | Yes | N/A | Virtual Machine #2 name |
| asyncExecution | bool | No | false | Optional. If set to true, provisioning will complete as soon as the script starts and will not wait for script to complete. |
| errorBlobContainerUri | string | Yes | N/A | The Azure storage blob container where script error stream will be uploaded to |
| outputBlobContainerUri | string | Yes | N/A | The Azure storage blob container where script output stream will be uploaded to |
| scriptParameters | array | No | N/A | The parameters used by the script. Required properties are: name, value |
| protectedScriptParameters | array | No | N/A | The protected parameters used by the script. Required properties are: name, value |
| now | string | No | utcNow() | Do not specify a value for this parameter. It is used get the current UTC time which is used to generate unique blob names. |
| timeoutInSeconds | int | No | 120 | The timeout in seconds to execute the run command. Minimum value is 120 seconds (2 minutes) and default value is 300 seconds (5 minutes). Maximum value is 5400 seconds (90 minutes). |


**A parameter file examples have been provided: [windows.parameters.json](./sample/windows.parameters.json)** 

#### Linux.bicep

The following Parameters must be specified for the [linux.bicep](./sample/linux.bicep) template:

| Name | Type | Mandatory | Default Value | Description |
| ---- | ---- | --------- | ------------- | ----------- |
| name | string | Yes | N/A | Run Command Name |
| vmName1 | string | Yes | N/A | Virtual Machine #1 name |
| vmName2 | string | Yes | N/A | Virtual Machine #2 name |
| asyncExecution | bool | No | false | Optional. If set to true, provisioning will complete as soon as the script starts and will not wait for script to complete. |
| errorBlobContainerUri | string | Yes | N/A | The Azure storage blob container where script error stream will be uploaded to |
| outputBlobContainerUri | string | Yes | N/A | The Azure storage blob container where script output stream will be uploaded to |
| scriptParameters | array | No | N/A | The parameters used by the script. The only required property is: value |
| protectedScriptParameters | array | No | N/A | The protected parameters used by the script. The only required property is: value |
| now | string | No | utcNow() | Do not specify a value for this parameter. It is used get the current UTC time which is used to generate unique blob names. |
| timeoutInSeconds | int | No | 120 | The timeout in seconds to execute the run command. Minimum value is 120 seconds (2 minutes) and default value is 300 seconds (5 minutes). Maximum value is 5400 seconds (90 minutes). |


**A parameter file examples have been provided: [linux.parameters.json](./sample/linux.parameters.json)** 

### Deploy VM Run Command Bicep template on Windows VMs

```bash
rg="rg-sql-vm-1"


# what-if
az deployment group what-if --resource-group $rg --template-file windows.bicep --parameters windows.parameters.json

#deploy
az deployment group create --name 'win-vm-run-cmd' --resource-group $rg --template-file windows.bicep --parameters windows.parameters.json --verbose
```

### Deploy VM Run Command Bicep template on Linux VMs

```bash
rg="rg-linux-jump-01"


# what-if
az deployment group what-if --resource-group $rg --template-file linux.bicep --parameters linux.parameters.json

#deploy
az deployment group create --name 'linux-vm-run-cmd' --resource-group $rg --template-file linux.bicep --parameters linux.parameters.json --verbose
```
