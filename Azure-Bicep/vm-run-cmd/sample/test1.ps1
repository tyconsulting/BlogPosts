[CmdletBinding()]
param (
  [parameter(Mandatory = $true)]
  [string]$content
)

$filePath = "C:\Temp\test.txt"
$userName = $env:UserName
$fileContent = "$username said: $content on $(get-date)"

if (!(test-path $filePath)) { new-item -Path $filePath -ItemType file -force }
Set-Content -Path $filePath -Value $fileContent
Write-Output $fileContent