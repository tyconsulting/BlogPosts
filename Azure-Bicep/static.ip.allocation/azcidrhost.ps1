#requires -Modules @{ModuleName='Az.Accounts';ModuleVersion='2.2.0'}

<#
===================================================================================================
AUTHOR: Tao Yang
DATE: 12/09/2022
NAME: pipeline-aad-lookup.ps1
VERSION: 0.0.1
COMMENT: Azure AD search for users, groups or AAD Applications using the Microsoft Graph REST API
===================================================================================================
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory = $true, Position = 0)][string]$addressPrefix,
  [Parameter(Mandatory = $false, Position = 1)]$indexes
)

<#
Note: https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets
 - 5 IPs reserved by Azure
  - x.x.x.0: Network address
  - x.x.x.1: Reserved by Azure for the default gateway
  - x.x.x.2, x.x.x.3: Reserved by Azure to map the Azure DNS IPs to the VNet space
  - x.x.x.255: Network broadcast address
#>
#region Functions

function ValidateAzAddressPrefix ($addressPrefix) {
  $NetworkID = $addressPrefix.split("/")[0]
  [int]$CIDR = $addressPrefix.split("/")[1]
  $script:binIP = (ConvertIPToBinary $NetworkID).Replace(".", "")
  $script:binIPAddressSection = $script:binIP.substring($CIDR, $(32 - $CIDR))

  $bValidAddressPrefix = $true

  # 1. make sure CIDR notation value is between 1 and 29
  if ($CIDR -lt 1 -or $CIDR -gt 29) {
    $bValidAddressPrefix = $false
  }

  # 2. make sure the address space must contain all "0"
  # network prefix length must equals, address space section must contain all "0"
  if ($script:binIPAddressSection -notmatch "^0{$(32-$CIDR)}$") {
    $bValidAddressPrefix = $false
  }
  $bValidAddressPrefix
}
function ValidateIP ($strIP) {
  $bValidIP = $true
  $arrSections = @()
  $arrSections += $strIP.split(".")
  #firstly, make sure there are 4 sections in the IP address
  if ($arrSections.count -ne 4) { $bValidIP = $false }

  #secondly, make sure it only contains numbers and it's between 0-254
  if ($bValidIP) {
    foreach ($item in $arrSections) {
      if ($item -notmatch "^\d{1,3}$") {
        $bValidIP = $false
      }
    }
  }

  if ($bValidIP) {
    foreach ($item in $arrSections) {
      $item = [int]$item
      if ($item -lt 0 -or $item -gt 254) { $bValidIP = $false }
    }
  }

  $bValidIP
}

function ConvertToBinary ($strDecimal) {
  $strBinary = [Convert]::ToString($strDecimal, 2)
  if ($strBinary.length -lt 8) {
    while ($strBinary.length -lt 8) {
      $strBinary = "0" + $strBinary
    }
  }
  $strBinary
}
function ConvertIPToBinary ($strIP) {
  $strBinaryIP = $null
  if (ValidateIP $strIP) {
    $arrSections = @()
    $arrSections += $strIP.split(".")
    foreach ($section in $arrSections) {
      if ($strBinaryIP -ne $null) {
        $strBinaryIP = $strBinaryIP + "."
      }
      $strBinaryIP = $strBinaryIP + (ConvertToBinary $section)

    }
  }
  $strBinaryIP
}

Function ConvertBinaryToIP ($script:binIP) {
  $FirstSection = [Convert]::ToInt64(($script:binIP.substring(0, 8)), 2)
  $SecondSection = [Convert]::ToInt64(($script:binIP.substring(8, 8)), 2)
  $ThirdSection = [Convert]::ToInt64(($script:binIP.substring(16, 8)), 2)
  $FourthSection = [Convert]::ToInt64(($script:binIP.substring(24, 8)), 2)
  $strIP = "$FirstSection`.$SecondSection`.$ThirdSection`.$FourthSection"
  $strIP
}

Function GetUsableIPByIndex ($index) {
  $binIndex = [convert]::ToString($index, 2)
  $indexIPReplaceStr = ""
  $i = 0
  do {
    [string]$indexIPReplaceStr = "$indexIPReplaceStr" + '0'
    $i = $i + 1
  } until ($i -eq $BinIndex.Length)
  $indexIPReplaceStr = $indexIPReplaceStr + '$'
  $indexIPSection = $script:binIPAddressSection -replace $indexIPReplaceStr, $BinIndex
  $BinIndexAddress = $script:binIPNetworkSection + $indexIPSection
  $indexIP = ConvertBinaryToIP $BinIndexAddress
  $indexIP
}
#endregion

#region Main
$arrIndexes = @()
if ($PSBoundParameters.ContainsKey("indexes")) {
  foreach ($item in $indexes) {
    $arrIndexes += [int]::Parse($item)
  }
}
$arrIndexes = $indexes -split (',')
Write-Verbose $addressPrefix

#validation
#validating AddressPrefix
Write-Verbose "Validating $addressPrefix"
if (!(ValidateAzAddressPrefix $addressPrefix)) {
  Throw "Invalid Network CIDR specified."
  Exit -1
} else {
  Write-verbose "Network ID $addressPrefix is valid"
}

$NetworkID = $addressPrefix.split("/")[0]
[int]$CIDR = $addressPrefix.split("/")[1]
$iAddressWidth = [System.Math]::Pow(2, $(32 - $CIDR))
[int]$AzSubnetSize = $iAddressWidth - 5 # 5 IPs are reserved by Azure

#Validating IP index (the index number must no exceed the total available IPs in the subnet)
if ($PSBoundParameters.ContainsKey('indexes')) {
  foreach ($index in $arrIndexes) {
    If ([int]$index -gt $AzSubnetSize) {
      Throw "There are $AzSubnetSize usable IPs in the subnet $addressPrefix. The index number $index must no exceed the total available usable IPs in the subnet."
      #exit -1
    }
  }
}

Write-Verbose "There are $AzSubnetSize usable IPs in Azure subnet $addressPrefix"

$script:binIP = (ConvertIPToBinary $NetworkID).Replace(".", "")
$script:binIPNetworkSection = $script:binIP.substring(0, $CIDR)
$script:binIPAddressSection = $script:binIP.substring($CIDR, $(32 - $CIDR))

#Azure Gateway IP
$strAzGWIP = GetUsableIPByIndex 1
Write-Verbose "The gateway IP for the Azure subnet is $strAzGWIP"

#Azure DNS Server IP #1
$strAzDNSIP1 = GetUsableIPByIndex 2
Write-Verbose "The 1st DNS server IP for the Azure subnet is $strAzDNSIP1"

#Azure DNS Server IP #2
$strAzDNSIP2 = GetUsableIPByIndex 3
Write-Verbose "The 2nd DNS server IP for the Azure subnet is $strAzDNSIP2"

#First Usable IP
$strAzFirstUsableIP = GetUsableIPByIndex 4 # excluding the first 3 reserved IPs
Write-Verbose "The First usable IP for the Azure subnet is $strAzFirstUsableIP"

if ($PSBoundParameters.ContainsKey('indexes')) {
  $htSelectedIPs = @{}
  foreach ($index in $arrIndexes) {
    #Index IP (The No. of USABLE IP)
    $usableIndex = [int]$index + 3 # considering the first 3 IPs in a subnet is reserved
    $strSelectedIP = GetUsableIPByIndex $usableIndex
    Write-Verbose "The select IP address for index $index is $strSelectedIP"
    $htSelectedIPs.add("IP$index", $strSelectedIP)
  }
}

#Last Usable IP
$strAzLastUsableIP = GetUsableIPByIndex $($AzSubnetSize + 3) # including the first 3 reserved IPs
Write-Verbose "The Last usable IP for the Azure subnet is $strAzLastUsableIP"


$DeploymentScriptOutputs = [ordered]@{}
if ($PSBoundParameters.ContainsKey('indexes')) {
  $DeploymentScriptOutputs["SelectedIPs"] = $htSelectedIPs
}
$DeploymentScriptOutputs['SubnetSize'] = $AzSubnetSize
$DeploymentScriptOutputs['GatewayIP'] = $strAzGWIP
$DeploymentScriptOutputs['DNSIP1'] = $strAzDNSIP1
$DeploymentScriptOutputs['DNSIP2'] = $strAzDNSIP2
$DeploymentScriptOutputs['FirstUsableIP'] = $strAzFirstUsableIP
$DeploymentScriptOutputs['LastUsableIP'] = $strAzLastUsableIP

$DeploymentScriptOutputs
#endregion