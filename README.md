# Password Expiration Notification FunctionApp and Proactive Remediation - Intune

- Azure Function App to serve as midddleware for a pw expiration notif solution for cloud managed devices in hybrid env. and Remdiation scripts
- Special thanks to you guys : https://www.smthwentright.com/2022/03/07/password-reminder-with-proactive-remediation-for-aad-joined-devices/ for the initial ideas
- Tested on Windows 10 and Windows 11

# Synchronize your internal password expiration policy with AzureAD
- Reference : https://learn.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-password-hash-synchronization#enforcecloudpasswordpolicyforpasswordsyncedusers
- You need to use PassSyncedUsers in AzureADConnect
- Be sure you're doing this outside working hours
- Configure the AzureAD Password expiration period in the admin portal (this should be the same than the internal one, and it's tenant wide, no different policies allowed)
- Connect to MSonline
- Type : Set-MsolDirSyncFeature -Feature EnforceCloudPasswordPolicyForPasswordSyncedUsers
- Connect to AzureAD
- Check account with : (Get-AzureADUser -objectID <User Object ID>).passwordpolicies
- If you want to activate this for synced users :  Get-AzureADUser -All $true | Where-Object {$_.DirSyncEnabled -eq $true} | Set-AzureADUser -PasswordPolicies None (Better to do it with a group)
- Don't forget to exclude the azureadsync user by using : Set-AzureADUser {AADSyncUser} -PasswordPolicies DisablePasswordExpiration
- Check : Get-AzureADUser -All $true | Where-Object {$_.DirSyncEnabled -eq $true} | Select UserPrincipalName,PasswordPolicies

# Installation
## 1. Create App Registration
- Create a new App Registration in AzureAD, name Company-LogonScript (Single Tenant, no redirect uri)
- Add API permissions : Directory.Read.All (application), User.Read.All (application)
- Create a secret and save the value
- Save the Client(app) ID, save the Tenant ID

## 2. Create an Azure Function
<img width="550" alt="image" src="https://user-images.githubusercontent.com/107478270/202721339-711e5cbf-b2e2-429a-92e6-bdac6daf528a.png">
- Add App Insight to monitor the function
- Create a slot for UAT
- Create environment variables for PRD and UAT (in configuration) :
    - client_id = yourclientID
    - client_secret = yourclientSecret
    - tenant_id = yourtenantID
- *Optional : you can enforce certificate auth in the azure function in strict env.
## 3. Clone the github repo
- Clone this repository
- *Optional : Create the env. variable for pipeline

## 4. Customize the files for the customer and deploy the function
- Connect VSCode to the GitHub repo
- Add desired paramters in the confqry.json (respect the schema)
    - You can use online images, just replace image path with http path
    - You can use special letters in text, in this case encode your string in Base64 and put the encoded string in the json instead of the text, then follow the procedure in the remediationScript to allow this
- Deploy the function to UAT by using Azure Functions:Deploy to Slot... in VSCode
- If tests are ok, deploy it to PRD by using Azure Functions:Deploy to Function App... in VSCode
- Gather the function URI and save it
- Change variable in remediation scripts ($client, $funcUri)


## 5. Create the proactive remediation in Intune
- Create a proactive remediation with these parameters :
    - Execute in User Context : Yes
    - Execute in Powershell64bits : Yes
- Assign it and don't forget to setup the schedule (at least once a day, better each 3hours) 
- Grab a coffee and wait :)
# Folder overview

- function-app contains the function app code that will be deployed to Azure
- proactive-remediation contains the code that will be packaged and deployed via Intune ProActive Remediation
- tests contains the pester tests to be used for interactive testing OR ci/cd deployment

# Pre-Reqs for local function app development and deployment

To develop and deploy the function app contained within this repository, please make sure you have the following reqs on your development environment.

- [Visual Studio Code](https://code.visualstudio.com/)
- The [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local#install-the-azure-functions-core-tools) version 2.x or later. The Core Tools package is downloaded and installed automatically when you start the project locally. Core Tools includes the entire Azure Functions runtime, so download and installation might take some time.
- [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows) recommended.
- Both [.NET Core 3.1](https://www.microsoft.com/net/download) runtime and [.NET Core 2.1 runtime](https://dotnet.microsoft.com/download/dotnet-core/2.1).
- The [PowerShell extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell).
- The [Azure Functions extension for Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=powershell#install-the-azure-functions-extension)
- The [Pester Tests extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=pspester.pester-test)
- The [Pester Tests Explorer extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=TylerLeonhardt.vscode-pester-test-adapter)
