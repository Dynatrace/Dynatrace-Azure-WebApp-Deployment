This script automates the Dynatrace OneAgent installation for the Azure WebApps PaaS-offering.

It basically adds the required application settings to your WebApps and installs the Dynatrace Site Extension (https://www.siteextensions.net/packages/Dynatrace).

Before using this script, you need to install the Azure PowerShell: https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/

After that, open a PowerShell window and type 'Add-AzureAccount'. Enter your Azure user-credentials in the prompt that pops up.

If you have multiple subscriptions make sure you select the subscription which contains your app. 

To list your subscriptions type 'Get-AzureRmSubscription'. To select a subscription type 'Select-AzureSubscription'.

usage:
.\dynatrace-azure-updater.ps1 `websitename` `deployment-username` `deployment-password` `tenant` `tenanktoken`

 * `websitename` the name of your Azure WebApp or API App
 * `deployment-username`/`deployment-password` Your azure deployment credentials, which you can set in the azure portal under "App Deployment" > "Deployment credentials"
 * `tenant`/`tenanktoken` Your Dynatrace environment ID and environment token, which you can find in Dynatrace under "Deploy Dynatrace"
