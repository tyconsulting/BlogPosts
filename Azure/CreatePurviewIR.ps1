#Requires -Modules Az.Resources

<#
================================================================================
AUTHOR: Tao Yang
DATE: 27/02/2023
NAME: CreatePurviewIR.ps1
VERSION: 0.0.1
COMMENT: Create Integration Runtime on Purview account
REFERENCE: https://blog.tyang.org/2023/03/11/purview-integration-runtime-script
================================================================================
#>
[CmdletBinding()]
param (
  [parameter(Mandatory = $true)]
  [string]$purviewAccountName,

  [parameter(Mandatory = $true)]
  [string]$resourceGroupName,

  [parameter(Mandatory = $true)]
  [string]$subscriptionId,

  [parameter(Mandatory = $true)]
  [string]$integrationRuntimeName,

  [parameter(Mandatory = $true)]
  [ValidateSet('SelfHosted', 'Managed')]
  [string]$kind,

  [parameter(Mandatory = $false)]
  [string]$integrationRuntimeDescription = 'Created by ADO pipeline'
)

#region functions
Function ListIntegrationRuntimes {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true)]
    [string]$scanEndpoint,

    [parameter(Mandatory = $true)]
    [string]$token
  )
  $url = "$scanEndpoint/integrationruntimes`?api-version=2022-07-01-preview"
  Write-verbose "URL for List Purview Integration Runtimes request: '$url'"
  $Header = @{
    'Authorization' = "Bearer $token"
    'Content-Type'  = 'application/json'
  }
  $response = Invoke-WebRequest -UseBasicParsing -Uri $url -Headers $Header -Method Get
  $result = $response.Content | ConvertFrom-Json
  $result.value
}

Function CreateIntegrationRuntimes {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true)]
    [string]$scanEndpoint,

    [parameter(Mandatory = $true)]
    [string]$name,

    [parameter(Mandatory = $true)]
    [string]$description,

    [parameter(Mandatory = $true)]
    [ValidateSet('SelfHosted', 'Managed')]
    [string]$kind,

    [parameter(Mandatory = $true)]
    [string]$token
  )

  $url = "$scanEndpoint/integrationruntimes/$name`?api-version=2022-07-01-preview"
  Write-verbose "URL for creating Purview Integration Runtimes request: '$url'"
  $Header = @{
    'Authorization' = "Bearer $token"
    'Content-Type'  = 'application/json'
  }
  $body = @{
    kind       = $kind
    properties = @{
      description = $description
    }
  } | convertTo-Json -Depth 3
  $response = Invoke-WebRequest -UseBasicParsing -Uri $url -Headers $Header -Body $body -Method PUT
  $result = $response.Content | ConvertFrom-Json
  $result
}

Function GetPurview {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true)]
    [string]$purviewAccountName,

    [parameter(Mandatory = $true)]
    [string]$resourceGroupName,

    [parameter(Mandatory = $true)]
    [string]$subscriptionId,

    [parameter(Mandatory = $true)]
    [string]$token
  )
  $url = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Purview/accounts/$purviewAccountName`?api-version=2021-07-01"
  $Header = @{
    'Authorization' = "Bearer $token"
    'Content-Type'  = 'application/json'
  }
  $response = Invoke-WebRequest -UseBasicParsing -Uri $url -Headers $Header -Method Get
  $result = $response.Content | ConvertFrom-Json
  $result
}
#endregion

#region main
#Get tokens
$armToken = (Get-AzAccessToken -ResourceUrl https://management.azure.com/).Token
$purviewToken = (Get-AzAccessToken -ResourceUrl https://purview.azure.net/).Token

Write-output "Getting Purview account $purviewAccountName in resource group $resourceGroupName, Subscription $subscriptionId"
$purviewAccount = GetPurview -purviewAccountName $purviewAccountName -resourceGroupName $resourceGroupName -subscriptionId $subscriptionId -token $armToken
if ($purviewAccount) {
  Write-Output " -- Purview account $purviewAccountName found."
  $scanEndpoint = $purviewAccount.properties.endpoints.scan
  Write-Output " -- Scan endpoint: $scanEndpoint"
} else {
  Write-Error " -- Purview account $purviewAccountName not found."
  Exit 1
}

if ($scanEndpoint) {
  Write-Output "Looking for existing $kind Integration Runtime with name $integrationRuntimeName in Purview account $purviewAccountName"
  $shir = ListIntegrationRuntimes -scanEndpoint $scanEndpoint -token $purviewToken | where-object { $_.kind -eq $kind -and $name -ieq $integrationRuntimeName }
  if ($shir) {
    Write-Output "  -- Self-Hosted Integration Runtime $($shir.name) already exists, no need to create it."
  } else {
    Write-Output "  -  Self-Hosted Integration Runtime $integrationRuntimeName does not exist, creating it now."
    $newShir = CreateIntegrationRuntimes -scanEndpoint $scanEndpoint -name $integrationRuntimeName -description $integrationRuntimeDescription -kind $kind -token $purviewToken
    $newShir
  }
}
Write-Output "Done."
#endregion