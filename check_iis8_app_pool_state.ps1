<#
Ester Niclos Ferreras

OK	UP
WARNING	
CRITICAL	Stopped
UNKNOWN	not found


#>


#
# Shell arguments
#
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$ApplicationPool
   )

Set-Variable OK 0 -option Constant
Set-Variable WARNING 1 -option Constant
Set-Variable CRITICAL 2 -option Constant
Set-Variable UNKNOWN 3 -option Constant


#
# ASK STATUS
#
#Load assembly
[System.Reflection.Assembly]::LoadFrom( "C:\windows\system32\inetsrv\Microsoft.Web.Administration.dll" )  >  $null

$servermanager = [Microsoft.Web.Administration.ServerManager]::OpenRemote("localhost")
$apppools = $servermanager.ApplicationPools["$ApplicationPool"]


$iis=get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring

# Nagios output
$status_str='IISPOOL UNKNOWN ' + $ApplicationPool + ' ' + $status +' ; ' + $iis.SETUPSTRING + ' '
$perf_data= "IISPOOL=" + "0" + ';' + "0" + ';' + "0" + "; "
$resultstring= "$status_str  |  $perf_data " 
$exit_code = $UNKNOWN


if ($apppools -ne $null)  {

  $status = $apppools.state
    
  if ($status -eq 'Started')
	{
		$status_str='IISPOOL OK '+  $ApplicationPool + ' ' + $status +' ; ' + $iis.SETUPSTRING + ' ' 
		$perf_data= "IISPOOL=" + "1" + ';' + "0" + ';' + "0" + "; "
		$resultstring= "$status_str  |  $perf_data "
		$exit_code = $OK
	}
	else
	{
   $status_str='IISPOOL CRITICAL '+  $ApplicationPool + ' ' + $status +' ; ' + $iis.SETUPSTRING + ' ' 
   $perf_data= "IISPOOL=" + "0" + ';' + "0" + ';' + "0" + "; "
   $resultstring= "$status_str  |  $perf_data "
   $exit_code = $CRITICAL
	}
}

Write-Host $resultstring
exit $exit_code

