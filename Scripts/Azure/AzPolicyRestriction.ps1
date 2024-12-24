#Requires -Module Az.Accounts

<#
.SYNOPSIS
Gets policy restrictions for a specified Azure resource.

.DESCRIPTION
The Get-AzPolicyRestriction function retrieves policy restrictions for a specified Azure resource by calling the Azure Policy Insights API. It supports checking restrictions at the management group, subscription, and resource group levels. The function returns a custom object containing the policy restrictions.

.PARAMETER managementGroupName
The name of the management group. This parameter is required when checking at Management Group level.

.PARAMETER subscriptionId
The ID of the subscription. This parameter is required when checking at Subscription and Resource Group levels.

.PARAMETER resourceGroupName
The name of the resource group. This parameter is required when checking at Resource Group level.

.PARAMETER pendingFields
The list of fields (name, location, tags, and type) and values that should be evaluated for potential restrictions. This parameter is optional.

.PARAMETER includeAuditEffect
Whether to include policies with the 'audit' effect in the results. The default value is true. This parameter is optional.

.PARAMETER resourceApiVersion
The API version of the resource content. This parameter is optional.

.PARAMETER resourceContent
The resource content. This should include whatever properties are already known and can be a partial set of all resource properties. This parameter is optional.

.PARAMETER resourceScope
The scope where the resource is being created. For example, if the resource is a child resource, this would be the parent resource's resource ID. This parameter is optional.

.EXAMPLE

PS C:\> Get-AzPolicyRestriction -managementGroupName "myManagementGroup"

This command retrieves policy restrictions for the specified management group. Only the 'type' pending field is checked since it's the only supported field at the management group level.

.EXAMPLE

PS C:\>  $params = @{
  subscriptionId      = '00000000-0000-0000-0000-000000000000'
  pendingFields       = @(
    @{
      field  = 'name'
      values = @('mystoragename')
    }
    @{
      field  = 'location'
      values = @('australiaeast', 'australiasoutheast')
    }
  )
  resourceApiVersion  = '2024-01-01'
  resourceContent     = @{
    type       = 'Microsoft.Storage/StorageAccounts'
    properties = @{
      minimumTlsVersion = 'TLS1_1'
    }
  }
}
PS C:\> Get-AzPolicyRestriction @params

This command retrieves policy restrictions for the specified subscription. It check for policy restrictions for the name and location fields and Storage Account with 'minimumTlsVersion' property set to 'TLS1_1'

.EXAMPLE

PS C:\> $params = @{
  subscriptionId      = '00000000-0000-0000-0000-000000000000'
  pendingFields       = @(
    @{
      field  = 'name'
      values = @('mystoragename')
    }
    @{
      field  = 'location'
      values = @('australiaeast', 'australiasoutheast', 'eastus')
    }
    @{
      field = 'tags'
    }
  )
  resourceApiVersion  = '2024-01-01'
  resourceContent     = @{
    type       = 'Microsoft.Storage/StorageAccounts'
  }
  includeAuditEffect = $false
}
PS C:\> Get-AzPolicyRestriction @params

This command retrieves policy restrictions for the specified subscription. It check for policy restrictions at the Subscription level for the name, location, and tags fields and resource type Storage Account, excluding Audit Effect policies.

.EXAMPLE

PS C:\> $params = @{
  subscriptionId      = '00000000-0000-0000-0000-000000000000'
  resourceGroupName   = 'myResourceGroup'
  pendingFields       = @(
    @{
      field  = 'location'
      values = @('australiaeast', 'australiasoutheast')
    }
  )
  resourceApiVersion  = '2024-01-01'
  resourceContent     = @{
    type       = 'Microsoft.Storage/StorageAccounts'
    properties = @{
      minimumTlsVersion = 'TLS1_1'
    }
  }
}
PS C:\> Get-AzPolicyRestriction @params

This command retrieves policy restrictions for the specified subscription. It check for policy restrictions for the location field and Storage Account with 'minimumTlsVersion' property set to 'TLS1_1'

.EXAMPLE

PS C:\> $params = @{
  subscriptionId      = '00000000-0000-0000-0000-000000000000'
  resourceGroupName   = 'myResourceGroup'
  resourceApiVersion  = '2024-01-01'
  resourceContent     = @{
    type       = 'Microsoft.Insights/diagnosticSettings'
  }
  resourceScope = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/mystoragename'
  includeAuditEffect = $true
}
PS C:\> Get-AzPolicyRestriction @params

This command retrieves policy restrictions for the specified subscription. It check for policy restrictions at the Resource group level for diagnostic settings of a storage account, including Audit Effect policies.
#>

Function Get-AzPolicyRestriction {
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  Param (
    [Parameter(ParameterSetName = 'mg', Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$managementGroupName,

    [Parameter(ParameterSetName = 'sub', Mandatory = $true)]
    [Parameter(ParameterSetName = 'rg', Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$subscriptionId,

    [Parameter(ParameterSetName = 'rg', Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$resourceGroupName,

    [Parameter(ParameterSetName = 'sub', Mandatory = $false, HelpMessage = 'The list of fields (name, location, tags and type) and values (name, location must contain values, type value is optional. tags must not contain values.) that should be evaluated for potential restrictions.')]
    [Parameter(ParameterSetName = 'rg', Mandatory = $false, HelpMessage = 'The list of fields (name, location, tags and type) and values (name, location must contain values, type value is optional. tags must not contain values.) that should be evaluated for potential restrictions.')]
    [Hashtable[]]$pendingFields,

    [Parameter(ParameterSetName = 'sub', Mandatory = $false, HelpMessage = "Whether to include policies with the 'audit' effect in the results.")]
    [Parameter(ParameterSetName = 'rg', Mandatory = $false, HelpMessage = "Whether to include policies with the 'audit' effect in the results.")]
    [bool]$includeAuditEffect = $true,

    [Parameter(ParameterSetName = 'sub', Mandatory = $false, HelpMessage = 'The api-version of the resource content.')]
    [Parameter(ParameterSetName = 'rg', Mandatory = $false, HelpMessage = 'The api-version of the resource content.')]
    [string]$resourceApiVersion,

    [Parameter(ParameterSetName = 'sub', Mandatory = $false, HelpMessage = 'The resource content. This should include whatever properties are already known and can be a partial set of all resource properties.')]
    [Parameter(ParameterSetName = 'rg', Mandatory = $false)]
    [hashtable]$resourceContent,

    [Parameter(ParameterSetName = 'sub', Mandatory = $false, HelpMessage = "The scope where the resource is being created. For example, if the resource is a child resource this would be the parent resource's resource ID.")]
    [Parameter(ParameterSetName = 'rg', Mandatory = $false, HelpMessage = "The scope where the resource is being created. For example, if the resource is a child resource this would be the parent resource's resource ID.")]
    [string]$resourceScope
  )
  Switch ($PSCmdlet.ParameterSetName) {
    'mg' { $uri = 'https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.PolicyInsights/checkPolicyRestrictions?api-version=2023-03-01' -f $ManagementGroupName }
    'sub' { $uri = 'https://management.azure.com/subscriptions/{0}/providers/Microsoft.PolicyInsights/checkPolicyRestrictions?api-version=2023-03-01' -f $SubscriptionId }
    'rg' { $uri = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.PolicyInsights/checkPolicyRestrictions?api-version=2023-03-01' -f $SubscriptionId, $resourceGroupName }
  }
  Write-Verbose "Request URI: '$uri'" -verbose

  # Get ARM token for accessing Azure VM
  $token = Get-AzAccessToken -ResourceUrl 'https://management.azure.com/' -AsSecureString -WarningAction SilentlyContinue
  $strToken = ConvertFrom-SecureString -SecureString $token.Token -AsPlainText
  $headers = @{
    Authorization  = "Bearer $strToken"
    'Content-Type' = 'application/json'
  }
  if ($PSCmdlet.ParameterSetName -eq 'mg') {
    $body = @{
      pendingFields = @(@{field = 'type' })
    }
  } else {
    $arrPendingFields = @()
    foreach ($pendingField in $pendingFields) {
      $arrPendingFields += $pendingField
    }
    $body = @{
      pendingFields      = $arrPendingFields
      includeAuditEffect = $includeAuditEffect
    }

    $resourceDetails = @{
      apiVersion = $resourceApiVersion
    }
    $resourceDetails.Add('resourceContent', $resourceContent)
    if ($PSBoundParameters.ContainsKey('resourceScope')) {
      $resourceDetails.add('scope', $resourceScope)
    }
    $body.add('resourceDetails', $resourceDetails)
  }

  $jsonBody = $body | ConvertTo-Json -Depth 100
  Write-Verbose "Request Body:" -verbose
  Write-Verbose $jsonBody -verbose
  $request = Invoke-WebRequest -method POST -Uri $uri -Headers $headers -body $jsonBody
  $result = $request.Content | ConvertFrom-Json
  $result
}
