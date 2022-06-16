#Set-StrictMode -Version Latest
#####################################################
# Test-Request
#####################################################
<#PSScriptInfo

.VERSION 0.1

.GUID f28b1e23-11fb-4b33-8dba-48ad1075e08d

.AUTHOR David Walker, Sitecore Dave, Radical Dave

.COMPANYNAME David Walker, Sitecore Dave, Radical Dave

.COPYRIGHT David Walker, Sitecore Dave, Radical Dave

.TAGS powershell sitecore package

.LICENSEURI https://github.com/SharedSitecore/Test-Request/blob/main/LICENSE

.PROJECTURI https://github.com/SharedSitecore/Test-Request

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
- 0.1 init
#>

<# 

.DESCRIPTION 
 PowerShell Script to Test-Request

.PARAMETER url
Url to test

#> 
#####################################################
# Test-Request
#####################################################
Param(
	[Parameter(Mandatory=$false)]
	[string]$url='',
	[Parameter(Mandatory=$false)]
	[string]$method='GET',
	[Parameter(Mandatory=$false)]
	[hashtable]$Params=@{},
	[Parameter(Mandatory=$false)]
	[string]$success='Healthy',
	[Parameter(Mandatory=$false)]
	[string]$retries=1,
	[Parameter(Mandatory=$false)]
    [string]$delay=2,
	[Parameter(Mandatory=$false)]
    [string]$timeout=120
)
begin {
	$ProgressPreference = "SilentlyContinue"		
	$ErrorActionPreference = 'Stop'
	$PSScriptName = ($MyInvocation.MyCommand.Name.Replace(".ps1",""))
	$PSCallingScript = if ($MyInvocation.PSCommandPath) { $MyInvocation.PSCommandPath | Split-Path -Parent } else { $null }
	Write-Verbose "$PSScriptRoot\$PSScriptName $url $method $success $retries called by:$PSCallingScript"

	$Params.Add('UserAgent', $PSScriptName)
	$Params.Add("Uri", $url)
	$Params.Add("Method", $method)
	$cmd = { Write-Host "$method $url..." -NoNewline; Invoke-WebRequest @Params }

	$retryCount = 0
	$completed = $false
	$response = $null

	while (-not $completed) {
		try {
			$response = Invoke-Command $cmd -ArgumentList $Params
			if ($response.StatusCode -ne 200) {
				throw "Expecting reponse code 200, was: $($response.StatusCode)"
			}
			$completed = $true
		} catch {
			Write-Output "$(Get-Date -Format G): Request to $url failed. $_"
			if ($retrycount -ge $retries) {
				Write-Error "Request to $url failed the maximum number of $retryCount times."
				throw
			} else {
				Write-Warning "Request to $url failed. Retrying in $delay seconds."
				Start-Sleep $delay
				$retrycount++
			}
		}
	}

	Write-Host "OK ($($response.StatusCode))"
	return $response
	
	$res = Req -Retries $retries -SecondsDelay $delay -Params @{ 'Method'=$method;'Uri'=$url;'TimeoutSec'=$timeout;'UseBasicParsing'=$true }
	
	if($res.Content -ne "$success")
	{
		Write-Error $response.Content
	}
	else
	{
		Write-Host "success"
	}
}
end {
	Write-Verbose "$PSScriptName $url $method $success $retries end"
}