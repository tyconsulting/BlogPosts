Function Get-AzureSQLDBDTU
{
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory = $true,HelpMessage = 'Please enter the number of processor cores')][int]$Core,
    [Parameter(Mandatory = $true,HelpMessage = 'Please enter the apiPerformanceItems input parameters in JSON format')][String]$apiPerformanceItems
  )
  $DUTCalculatorUri = "http://dtucalculator.azurewebsites.net/api/calculate?cores=$cores"
  try
  {
    $Response = Invoke-WebRequest -UseBasicParsing -Headers @{
      'Content-Type' = 'application/json'
    } -Uri $DUTCalculatorUri -Body $apiPerformanceItems -Method Post
  }
  catch 
  {
    throw 'failed to invoke the REST API.'
    Exit -1
  }


  If ($Response.StatusCode -eq 200)
  {
    Write-Verbose 'Response received.'
    $ResponseContent = ConvertFrom-Json -InputObject $Response.Content
  }
  $ResponseContent
}