$NPMDPath = "HKLM:\Software\Microsoft\NPMD"
$portNumberName = "PortNumber"
if(!(Test-Path -Path $NPMDPath))
{
    Write-Output "OMS Network Performance Monitor is NOT enable on computer $env:ComputerName"
}
else
{
    $NPMDKeys = Get-Item -Path $NPMDPath
	$ConfiguredPort = $NPMDKeys.GetValue($portNumberName)
    if ( $ConfiguredPort -eq $null) 
    {
        Write-Output "OMS Network Performance Monitor is partially configured on computer $env:ComputerName. The Port number is not configured"
    } 
    elseif ($NPMDKeys.GetValueKind($portNumberName) -ne "DWORD") 
    {
        Write-Output "OMS Network Performance Monitor is incorrectly configured on computer $env:ComputerName. The '$portNumberName' should be a DWORD value."
    }
    else
    {
       Write-Output "OMS Network Performance Monitor is enabled on computer $env:ComputerName. It is configured to use port $ConfiguredPort."
    }            
}