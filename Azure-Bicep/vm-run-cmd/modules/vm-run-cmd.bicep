@description('The Run Command resource name.')
param name string

@description('The Virtual Machine location.')
param location string = resourceGroup().location

@description('Optional. If set to true, provisioning will complete as soon as the script starts and will not wait for script to complete.')
param asyncExecution bool = false

@description('The Azure storage blob where script error stream will be uploaded to')
param errorBlobUri string = ''

@description('The Azure storage blob where script output stream will be uploaded to')
param outputBlobUri string = ''

@description('The parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value')
param scriptParameters array = []

@description('The protected parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value')
param protectedScriptParameters array = []

@description('Specifies a commandId of predefined built-in script. i.e. \'RunPowerShellScript\' for Windows or \'RunShellScript\' for Linux')
param commandId string = ''

@description('The script content to be executed on the VM. required when the commandId and scriptUri are not specified.')
param script string = ''

@description('The script download location. required when the commandId and script are not specified.')
param scriptUri string = ''

@description('The timeout in seconds to execute the run command. Minimum value is 120 seconds (2 minutes) and default value is 300 seconds (5 minutes). Maximum value is 5400 seconds (90 minutes).')
@minValue(120)
@maxValue(5400)
param timeoutInSeconds int = 120

//RunPowerShellScript for Windows and RunShellScript for Linux is not required when the commandId is specified.
var commandId_var = commandId =~ 'RunPowerShellScript' || commandId =~ 'RunShellScript' ? '' : commandId
var scriptSource = {
  script: script
}

var scriptUriSource = {
  scriptUri: scriptUri
}

var commandIdSource = {
  commandId: commandId_var
}
var scriptUri_var = empty(scriptUri) ? null : scriptUri
var source_var = empty(commandId_var) ? (empty(scriptUri) ? scriptSource : scriptUriSource) : commandIdSource
resource vm_run_cmd 'Microsoft.Compute/virtualMachines/runCommands@2021-07-01' = {
  name: name
  location: location
  properties: {
    asyncExecution: asyncExecution
    errorBlobUri: errorBlobUri
    outputBlobUri: outputBlobUri
    parameters: scriptParameters
    protectedParameters: protectedScriptParameters
    source: source_var
    timeoutInSeconds: timeoutInSeconds
  }
}

output id string = vm_run_cmd.id
output source object = source_var  
output name string = vm_run_cmd.name
output result object = vm_run_cmd
