This script automates the Dynatrace Agent installation for Azure WebApps

Before using this script, you need to install the Azure PowerShell: https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/
After that, open a PowerShell window and type 'add-azureaccount'. Enter your azure user-credentials in the prompt that pops up.

usage:
.\dynatrace-azure-updater.ps1 <websitename> <deployment-username> <deployment-password> <tenant> <tenanktoken>

<websitename> the name of your Azure WebApp
<deployment-username>/<deployment-password> Your azure deployment credentials, which you can set in the azure portal under "App Deployment" > "Deployment credentials"
<tenant>/<tenanktoken> Your Dynatrace tenantid (environmentid) and tenant token, which you can find in Dynatrace under "Deploy Dynatrace"
