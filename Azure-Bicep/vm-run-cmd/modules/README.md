# VM Run Command Bicep Module

## Instructions

### Module Parameters

The following Parameters must be specified for the [vm-run-cmd.bicep](./vm-run-cmd.bicep) module:

| Name | Type | Mandatory | Default Value | Description |
| ---- | ---- | --------- | ------------- | ----------- |
| name | string | Yes | N/A | The Run Command resource name |
| location| string | No | Resource Group location | Virtual Machine location |
| asyncExecution | bool | No | false | Optional. If set to true, provisioning will complete as soon as the script starts and will not wait for script to complete. |
| errorBlobUri | string | No | N/A | The Azure storage blob where script error stream will be uploaded to |
| outputBlobUri | string | No | N/A | The Azure storage blob where script output stream will be uploaded to |
|scriptParameters | array | No | N/A | The parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value' |
| protectedScriptParameters | array | No | N/A | The protected parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value |
| commandId | Specifies a commandId of predefined built-in script. i.e. \'IPConfig\' for Windows or \'ifconfig\' for Linux'. Do not specify this parameter together with the 'script' or 'scriptUri' parameters. Refer to [Available Commands](#available-commands) for the list of available commands for both Windows and Linux |
| script | string | No | N/A | The script content to be executed on the VM. required when the commandId and scriptUri are not specified. |
| scriptUri | string | No | N/A | The script download location. required when the commandId and script are not specified. |
| timeoutInSeconds | int | No | 120 | The timeout in seconds to execute the run command. Minimum value is 120 seconds (2 minutes) and default value is 300 seconds (5 minutes). Maximum value is 5400 seconds (90 minutes). |

### Available Commands

#### Windows

| **Name** | Description |
| :------- | :---------- |
| **RunPowerShellScript**	| Runs a PowerShell script, No need to specify this value to the commandId parameter.|
| **DisableNLA** | Disable Network Level Authentication |
| **DisableWindowsUpdate** | Disable Windows Update Automatic Updates |
| **EnableAdminAccount** | Checks if the local administrator account is disabled, and if so enables it. |
| **EnableEMS** | EnableS EMS |
| **EnableRemotePS**| Configures the machine to enable remote PowerShell. |
| **EnableWindowsUpdate** | Enable Windows Update Automatic Updates |
| **IPConfig** |Shows detailed information for the IP address, subnet mask, and default gateway for each adapter bound to TCP/IP. |
| **RDPSetting** | Checks registry settings and domain policy settings. Suggests policy actions if the machine is part of a domain or modifies the settings to default values. |
| **ResetRDPCert** | Removes the TLS/SSL certificate tied to the RDP listener and restores the RDP listener security to default. Use this script if you see any issues with the certificate. |
| **SetRDPPort** | Sets the default or user-specified port number for Remote Desktop connections. Enables firewall rules for inbound access to the port. |

#### Linux

| **Name** | Description |
| :------- | :---------- |
| **RunShellScript** | Executes a Linux shell script. No need to specify this value to the commandId parameter. |
| **ifconfig** | List network configuration |
