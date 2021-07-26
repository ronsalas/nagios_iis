<#
Ester Niclos Ferreras

Checks IIS Site state

OK - started
CRITICAL - STOPPED
UNKNOWN - not found


#>


#
# Shell arguments
#
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$website
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

$site= $servermanager.Sites["$website"]

$iis=get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring

# Nagios output

$status_str="IISSITE UNKNOWN  $website not found"
$perf_data= "IISSITE=" + "0" + ';' + ';' + "; "
$resultstring= "$status_str  |  $perf_data " 
$exit_code = $UNKNOWN
  
if ($site -ne $null) {
      
  $status= $site.State
  
  if ($status -eq "Started"){
    $status_str='IISSITE OK ' + $website + ' ' + $status + '-' + $iis.setupstring
    $pdata= 1
    $exit_code = $OK
  }
  elseif ($status -eq $null) {
	$status_str="IISSITE UNKNOWN  $website exists, but has no state. Check it is not a FTP site."
	$pdata= 0
  }
  else
  {	
	$status_str='IISSITE CRITICAL '+ $website + ' ' + $status + '-' + $iis.setupstring
	$pdata= 0
	$exit_code = $CRITICAL
  }
  $perf_data= "IISSITE=" + $pdata + ';' + ';' + "; "
  $resultstring= "$status_str  |  $perf_data " 
}




Write-Host $resultstring
exit $exit_code

