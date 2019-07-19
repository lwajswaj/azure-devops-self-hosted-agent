# azureDeploy.json
Azure ARM Template to deploy a Windows Server 2016 VM with a Custom Script extension to configure Azure DevOps agent; it deploys:

* a Network Interface
* a Storage Account for Diagnostics
* a Virtual Machine with Managed Disks and smalldisks
* a Custom Script extesion

## Parameters
| Name | Type | Mandatory | Description |
| --- | --- | --- | --- |
| virtualMachineName | String | Yes | Self-explanatory |
| operatingSystem | String | No | Operating system SKU to be used. Allowed values: "2016-Datacenter-smalldisk" or "2016-Datacenter-Server-Core-smalldisk" being this last one the default value. |
| existingVirtualNetworkResourceGroupName | String | Yes | Name of the Resource Group where the VNET has been deployed |
| existingVirtualNetworkName | String | Yes | Name of the VNET to use |
| existingSubnetName | String | Yes | Name of the Subnet to use |
| adminUsername | String | Yes | User name for the computer's local administrator |
| adminPassword | securestring | Yes | Password for the computer's local administrator |
| TeamAccount | String | Yes | If your URL is "https://abc.visualstudio.com", then you should set this to "abc"  |
| PoolName | String | Yes | Agent Pool name to configure this agent to |
| PATToken | securestring | Yes | Personal Access Token to use when configuring Azure DevOps agent |