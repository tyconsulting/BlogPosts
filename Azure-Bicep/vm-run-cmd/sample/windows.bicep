@description('Run Command Name.')
param name string

@description('Virtual Machine #1 name.')
param vmName1 string

@description('Virtual Machine #2 name.')
param vmName2 string

@description('Optional. If set to true, provisioning will complete as soon as the script starts and will not wait for script to complete.')
param asyncExecution bool = false

@description('The Azure storage blob container where script error stream will be uploaded to')
param errorBlobContainerUri string

@description('The Azure storage blob container where script output stream will be uploaded to')
param outputBlobContainerUri string

@description('The parameters used by the script. Required properties are: name, value')
param scriptParameters array = []

@description('The protected parameters used by the script. Required properties are: name, value')
param protectedScriptParameters array = []

@description('Do not specify a value for this parameter. It is used get the current UTC time which is used to generate unique blob names.')
param now string = utcNow()

@description('The timeout in seconds to execute the run command. Minimum value is 120 seconds (2 minutes) and default value is 300 seconds (5 minutes). Maximum value is 5400 seconds (90 minutes).')
@minValue(120)
@maxValue(5400)
param timeoutInSeconds int = 120

var blobNameSuffix1 = substring(guid(vmName1, now), 0, 5)
var blobNameSuffix2 = substring(guid(vmName2, now), 0, 5)
var blobName1 = '${vmName1}-${blobNameSuffix1}.txt'
var blobName2 = '${vmName2}-${blobNameSuffix2}.txt'
var outputBlobUri1 = '${outputBlobContainerUri}/${blobName1}'
var outputBlobUri2 = '${outputBlobContainerUri}/${blobName2}'
var errorBlobUri1 = '${errorBlobContainerUri}/${blobName1}'
var errorBlobUri2 = '${errorBlobContainerUri}/${blobName2}'
var vmResourceId1 = resourceId(resourceGroup().name, 'Microsoft.Compute/virtualMachines', vmName1)
var vmResourceId2 = resourceId(resourceGroup().name, 'Microsoft.Compute/virtualMachines', vmName2)
var location1 = reference(vmResourceId1, '2021-07-01', 'full').location
var location2 = reference(vmResourceId2, '2021-07-01', 'full').location
var scriptContent1 = loadTextContent('test1.ps1', 'utf-8')

module win_vm_run_cmd_1 '../modules/vm-run-cmd.bicep' = {
  name: 'winVmRunCmd1'
  params: {
    name: '${vmName1}/${name}'
    location: location1
    asyncExecution: asyncExecution
    errorBlobUri: errorBlobUri1
    outputBlobUri: outputBlobUri1
    scriptParameters: scriptParameters
    protectedScriptParameters: protectedScriptParameters
    commandId: 'RunPowerShellScript'
    script: scriptContent1
    timeoutInSeconds: timeoutInSeconds
  }
}

output run_cmd_output1 object = win_vm_run_cmd_1.outputs.result
output source1 object = win_vm_run_cmd_1.outputs.source
output errorBlobUri1 string = errorBlobUri1
output outputBlobUri1 string = outputBlobUri1

module win_vm_run_cmd_2 '../modules/vm-run-cmd.bicep' = {
  name: 'winVmRunCmd2'
  params: {
    name: '${vmName2}/ipconfig'
    location: location2
    asyncExecution: asyncExecution
    errorBlobUri: errorBlobUri2
    outputBlobUri: outputBlobUri2
    commandId: 'IPConfig'
    timeoutInSeconds: timeoutInSeconds
  }
}
output run_cmd_output2 object = win_vm_run_cmd_2.outputs.result
output source2 object = win_vm_run_cmd_2.outputs.source
output errorBlobUri2 string = errorBlobUri2
output outputBlobUri2 string = outputBlobUri2
