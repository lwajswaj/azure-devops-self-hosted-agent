# Build and Deploy a Windows Self-Hosted agent

This repository contains all the automation necessary to deploy and configure a Windows self-hosted agent which is able to support the tasks for:

* Azure Resource Group deployment
* Azure App Service deployment
* Azure SQL database deployment
* Azure Powershell

Files included in this repo are:

* azuredeploy.json: *for deploying into Azure*
* Configure-Agent.ps1: *to install all the required software and configure Azure DevOps agent*
* software.json: *definition of software to be installeD*

In order to connect a self-hosted agent to Azure DevOps, you need to generate a [Personal Access Token (PAT)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts#create-personal-access-tokens-to-authenticate-access)