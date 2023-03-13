#requires -Modules Az.Accounts

<#
===========================================
AUTHOR: Tao Yang
DATE: 13/03/2023
NAME: deployADF.ps1
VERSION: 1.0.0
COMMENT: Deploy ADF with Global Parameters
===========================================
#>
[CmdletBinding()]
param (
  [parameter(Mandatory = $true)]
  [string]$subscriptionId,

  [parameter(Mandatory = $true)]
  [string]$resourceGroup,

  [parameter(Mandatory = $true)]
  [string]$templateFile,

  [parameter(Mandatory = $true)]
  [string]$templateParameterFile
)


$TemplateParameterFileDir = Split-Path -Parent $templateParameterFile
$UpdatedParameterFile = join-path $TemplateParameterFileDir 'updated.parameters.json'

#Set AZ Context
Set-AzContext -Subscription $subscriptionId

#Read Template Parameter File
$parameterFileJson = Get-Content $templateParameterFile -Raw | ConvertFrom-Json
$datafactoryName = $parameterFileJson.parameters.name.value
$deployParameters = @{
  ResourceGroupName = $resourceGroup
  TemplateFile      = $templateFile
  DeploymentName    = $datafactoryName
  Force             = $true
}
#Get existing ADF
Write-Output "Get Existing ADF $datafactoryName"

$adf = Get-AzResource -ResourceGroupName $resourceGroup -ResourceName $datafactoryName -ResourceType 'Microsoft.DataFactory/factories' -ApiVersion 2018-06-01 -ExpandProperties -ErrorAction SilentlyContinue

if ($adf) {
  Write-Output "ADF $dataFactoryName exists. Retrieving Global Parameters"
  $globalParameters = $adf | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty globalParameters
  if ($globalParameters) {
    Write-Output "Global Parameters found. Updating Global Parameters"
    $globalParameters
  }
  $parameterFileJson.parameters.globalParameters.value = $globalParameters
  $deployParameters.add('TemplateParameterFile', $UpdatedParameterFile)
  #Save updated Parameter File
  $parameterFileJson | ConvertTo-Json -Depth 10 | Set-Content $UpdatedParameterFile

} else {
  Write-Output "ADF $dataFactoryName does not exist. No need to update the GlobalParameter parameter value"
  $deployParameters.add('TemplateParameterFile', $templateParameterFile)
}

Write-Output "Deploy ADF $datafactoryName"

New-AzResourceGroupDeployment @deployParameters
