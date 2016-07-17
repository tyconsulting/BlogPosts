Function Get-AzureSQLDBElasticPoolDTU
{
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory = $true,HelpMessage = 'Please enter the number of processor cores')][int]$Core,
    [Parameter(Mandatory = $true,HelpMessage = 'Please enter the apiPoolPerfItems input parameters in JSON format')][String]$apiPoolPerfItems
  )
  $DUTCalculatorUri = 'http://dtucalculator.azurewebsites.net/api/calculatepool'

  try
  {
    $Response = Invoke-WebRequest -UseBasicParsing -Headers @{
      'Content-Type' = 'application/json'
    } -Uri $DUTCalculatorUri -Body $apiPoolPerfItems -Method Post
  }
  catch 
  {
    throw 'failed to invoke the REST API.'
  }


  If ($Response.StatusCode -eq 200)
  {
    Write-Verbose 'Response received.'
    $ResponseContent = ConvertFrom-Json -InputObject $Response.Content
  }
  
  $ResponseContent
}