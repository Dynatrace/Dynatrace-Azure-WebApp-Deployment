# This script automates the Dynatrace Agent installation for Azure WebApps
#
# Before using this script, you need to install the Azure PowerShell: https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/
# After that, open a PowerShell window and type 'add-azureaccount'. Enter your azure user-credentials in the prompt that pops up.
# If you have multiple subscriptions make sure you select the subscription which contains your app. 
# To list your subscriptions type 'Get-AzureRmSubscription'. To select a subscription type 'Select-AzureSubscription'.
#
# usage:
# .\dynatrace-azure-updater.ps1 <websitename> <deployment-username> <deployment-password> <tenant> <tenanktoken>
#
# <websitename> the name of your Azure WebApp
# <deployment-username>/<deployment-password> Your azure deployment credentials, which you can set in the azure portal under "App Deployment" > "Deployment credentials"
# <tenant>/<tenanktoken> Your Dynatrace tenantid (environmentid) and tenant token, which you can find in Dynatrace under "Deploy Dynatrace"

param (
	[Parameter(Mandatory=$true)][string]$websitename,
	[Parameter(Mandatory=$true)][string]$username,
    [string]$password = $( Read-Host "Input password, please" ),
	[Parameter(Mandatory=$true)][string]$tenant,
	[Parameter(Mandatory=$true)][string]$tenanttoken
)

# ==================================================
# function section
# ==================================================

function Log($level, $content) {	
	$line = "{0} {1} {2}" -f (Get-Date), $level, $content
	Write-Output ("LOG: {0}" -f $line)
}

function LogInfo($content) {	
	Log "INFO" $content
}

function LogWarning($content) {	
	Log "WARNING" $content
}

function LogError($content) {	
	if ($_.Exception -ne $null) {
		Log "ERROR" ("Exception.Message = {0}" -f $_.Exception.Message)
	}
	Log "ERROR" $content
}

function ExitFailed() {
	Log "ABORT" "Installation failed. See log.txt for more information."
	Exit 
}

function ExitSuccess() {
	Exit
}

# ==================================================
# main script
# ==================================================

LogInfo "getting site-info for '$websitename'..."

# update appsettings
try {
	$website = Get-AzureWebsite $websitename

	LogInfo "updating settings for '$websitename'..."
	$website.AppSettings['RUXIT_TENANT'] = $tenant
	$website.AppSettings['RUXIT_TENANTTOKEN'] = $tenanttoken
	$website.AppSettings['WEBSITE_PRIVATE_EXTENSIONS'] = '0' # disable all extensions to recover from potentially corrupted installations
	Set-AzureWebsite $websitename -AppSettings $website.AppSettings
} catch {		
	$ErrorMessage = $_.Exception.Message
	LogError "error accessing website via Azure PowerShell: $ErrorMessage"
	ExitFailed
}

try {
	$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

	$apiBaseUrl = "https://$websitename.scm.azurewebsites.net/api"

	# uninstall extension
	LogInfo "uninstalling extension for '$websitename'..."
	Invoke-RestMethod -Uri "$apiBaseUrl/siteextensions/ruxitAgent" -Method DELETE -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

	# install extension
	LogInfo "installing extension for '$websitename'..."
	Invoke-RestMethod -Uri "$apiBaseUrl/siteextensions/ruxitAgent" -Method PUT -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

	# get log file
	LogInfo "SiteExtensions/ruxitAgent/log.txt"
	LogInfo "================================="
	Invoke-RestMethod -Uri "$apiBaseUrl/vfs/SiteExtensions/ruxitAgent/log.txt" -Method GET -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

	$website.AppSettings['WEBSITE_PRIVATE_EXTENSIONS'] = '1' # re-enable extensions
	Set-AzureWebsite $websitename -AppSettings $website.AppSettings
} catch {		
	$ErrorMessage = $_.Exception.Message
	LogError "error accessing website via Azure PowerShell: $ErrorMessage"
	ExitFailed
}

LogInfo "finished"
ExitSuccess
