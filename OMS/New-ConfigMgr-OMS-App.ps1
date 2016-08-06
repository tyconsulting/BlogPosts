#requires -Modules AzureRM.profile, AzureRM.Resources
#requires -Version 2
#Requires -RunAsAdministrator


Function New-Passowrd
{
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory = $true)][int]$Length,
    [Parameter(Mandatory = $true)][int]$NumberOfSpecialCharacters
  )
  Add-Type -AssemblyName System.Web
  [Web.Security.Membership]::GeneratePassword($Length,$NumberOfSpecialCharacters)
}

#Login to Azure
Write-Output "Please login to Azure using an admin account from the Azure AD that's associated to your subscription."
$AzureAccount = Add-AzureRmAccount

#Make sure it's logged in to Azure
try {
  $Context = Get-AzureRmContext
} catch {
  throw 'Unable to detect azure context, please make sure you have signed in to Azure.'
  Exit -1
}


#Get Azure Subscriptions
$subscriptions = Get-AzureRmSubscription
If ($subscriptions -eq $null)
{
  Write-Error 'No Azure Subscription found!'
  Exit -1
}

Write-Output 'Select an Azure Subscription'
$menu = @{}
for ($i = 1;$i -le $subscriptions.count; $i++) 
{
  Write-Host -Object "$i. $($subscriptions[$i-1].SubscriptionName)"
  $menu.Add($i,($subscriptions[$i-1].SubscriptionId))
}

[int]$ans = Read-Host -Prompt 'Enter selection'
$subscriptionID = $menu.Item($ans)
$subscription = Get-AzureRmSubscription -SubscriptionId $subscriptionID
$tenant = Get-AzureRmTenant -TenantId $subscription.TenantId
#Set-AzureRmContext -SubscriptionName $subscription.SubscriptionName

#Create the application
#Application Name
$ApplicationDisplayName = Read-Host -Prompt 'Enter application name (or press enter to accept the default name "ConfigMgr-OMS-Connector")'
if ($ApplicationDisplayName.Length -eq 0) 
{
  $ApplicationDisplayName = 'ConfigMgr-OMS-Connector'
}
$NewPassword = New-Passowrd -Length 20 -NumberOfSpecialCharacters 0

$Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ('http://' + $ApplicationDisplayName) -IdentifierUris ('http://' + $ApplicationDisplayName) -Password $NewPassword
$ApplicationServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $Application.ApplicationId
#Get-AzureRmADServicePrincipal |   Where-Object -FilterScript { $_.ApplicationId -eq $Application.ApplicationId}

$NewRole = $null
$Retries = 0
While ($NewRole -eq $null -and $Retries -le 5)
{
  # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
  Start-Sleep -Seconds 10
  New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 10
  $NewRole = Get-AzureRmRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
  $Retries++
}
Write-Output -InputObject "Tenant: '$($tenant.Domain)'"
Write-Output -InputObject "Client ID: '$($Application.ApplicationId)'"
Write-Output -InputObject "Client Secret Key: '$NewPassword'"