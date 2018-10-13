# Configure-Agent
This script is responsible for processing software.json based on the parameters it received. It will also:

* Install NuGet (version 2.8.5.201 or higher) package provider in Powershell
* Configure "PSGallery" powershell repository as "Trusted"

## Pre-Requirements
* It must be executed with **Administrative Rights** since it makes changes to the Operating System.
* Software.json must be placed in the same folder as this script.
* [Personal Access Token (PAT)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts#create-personal-access-tokens-to-authenticate-access) must be generated before running this script.

## Syntax
```powershell
.\Configure-Agent.ps1 -TeamAccount <string> -PoolName <string> -PATToken <string> [<DynamicParam>] [<CommonParameters>]
```

## Parameters
Table describing each of the parameters:

| Name | Type | Mandatory | Description |
| --- | --- | --- | --- |
| TeamAccount | String | Yes | Team Account name. If you Azure DevOps Url is https://xyz.visualstudio.com, then Team Account name is "xyz" |
| PoolName | String | No | Agent Pool name to configure this agent to. Default value is "default" |
| PATToken | String | Yes | [Personal Access Token (PAT)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts#create-personal-access-tokens-to-authenticate-access) to use when configuring the agent. |
| <*DynamicParam*> | Switch | No | Based on software.json content, dynamic parameters will be added matching "<software-name>" |

## How software.json is processed
All properties for a "software-name" in software.json are optional (If you haven't already, get familiar with [software.json syntax](software.md)) and they get processed pretty much in an independent manner. This is the order and the conditions to process each section:

1. If there are **PreRequirements**, they will get processed first. (that's why they are "pre", right?)
2. If **Uri** is defined, then it will download the file to "C:\Packages\AzureDevOpsAgent". If it's a zip file, it will automatically expanded. If **Hash** is provided, after downloading the file, it will verify the hash matches, if it doesn't, it will abort the whole process.
3. If **Cmdline** is defined, it will be executed with the arguments provided in **Arguments** property (if provided). If the file in *CmdLine* is an MSI, it will be installed with msiexec with the following arguments " /qn ALLUSERS=1 REBOOT=ReallySuppress"
4. If **PSLine** is defined, that powershell line will be executed.
5. If **AddToPath** is defined, it will be added to the system PATH environmental variable
6. If **EnvironmentalVariables** is defined, then each one will be created or updated.