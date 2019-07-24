# Installing software duging self-hosted agent 
This file will explain the formatting of the software.json file and how to add additional software.

## Formatting
In short, the software.json file is a giant hash-table of packages that will be called in the configuration file. Below is a quick example of how the file looks 

```json
{
  "<package>": {
  	<specifications>
  },
  
  "<another-package>": {
  	<specifications>
  }
}
```
See azuredeploy.md to see how these packages are utilized. 

#### Specification Values
The following values are all possible options

| Uri | string | Not required | Url to the software to download |
| Hash | string | Not required | Hash value of the return product of the url |
| How to find the hash example for python 3.7.4.exe| Get-FileHash .\python-3.7.4-amd64.exe -Algorithm SHA256 | Value: BAB92F987320975C7826171A072BFD64F8F0941AAF2CDEBA6924B7025C9968A3|

| HashType | string | No | Supported values: MD5, SHA, SHA256, SHA384, SHA512 |
| PSLine | string | No | Powershell line to be executed |
| CmdLine | string | No | Command to be executed |
| Arguments | string | No | Arguments to be used with CmdLine |
| AddToPath | string | No | Value to be added to Windows PATH environmental variable |
| EnvironmentalVariables | object | No | Array of [EnvironmentalVariable](#EnvironmentalVariable-object) object |
| PreRequirements | object | No | Array of [SoftwareDefinition](#SoftwareDefinition-object) object |

### EnvironmentalVariable object
The following tables describe the values you need to set in the object.

| Name | Type | Required | Value |
| --- | --- | --- | --- |
| Name | string | Yes | Name of the Environmental Variable |
| Value | string | Yes | Value to set the Environmental variable to |

## Examples

### Example 1

The following example defines "SQLPackage" as a software:
* with DACFX as pre-requirement
* that must be downloaded "https://download.microsoft.com/download/3/5/A/35A485C7-E84E-410F-8334-C5E10377FFC0/SSDT-Setup-ENU.exe" with a SHA256 hash equals to "4CA5B3B06B6545EFDECB611217B595CB5A576F06E51E9254A90925F01DADFAE4".
* must be executing "SSDT-Setup-ENU.exe" with "/install INSTALLVSSQL /quiet /norestart" as arguments.
* should add "C:\Program Files\Microsoft SQL Server\140\DAC\bin\" to System PATH variable
* should create/set an environmental variable called "SqlPackage" set to "C:\Program Files\Microsoft SQL Server\140\DAC\bin\SqlPackage.exe"

```json
{
  "SQLPackage":{
    "Uri": "https://download.microsoft.com/download/3/5/A/35A485C7-E84E-410F-8334-C5E10377FFC0/SSDT-Setup-ENU.exe",
    "Hash": "4CA5B3B06B6545EFDECB611217B595CB5A576F06E51E9254A90925F01DADFAE4",
    "HashType": "SHA256",
    "CmdLine": "SSDT-Setup-ENU.exe",
    "Arguments": "/install INSTALLVSSQL /quiet /norestart",
    "AddToPath": "C:\\Program Files\\Microsoft SQL Server\\140\\DAC\\bin\\",
    "EnvironmentalVariables": [
      {
        "Name": "SqlPackage",
        "Value": "C:\\Program Files\\Microsoft SQL Server\\140\\DAC\\bin\\SqlPackage.exe"
      }
    ],
    "PreRequirements": [
      {
        "DACFX":{
          "Uri": "https://download.microsoft.com/download/D/5/C/D5CFC940-DA21-44D3-84FF-A0FD147F1681/EN/x86/DacFramework.msi",
          "Hash": "665BCC245092C0CD3EA091CC460246F88631AE219003A003548221507219AC74",
          "HashType": "SHA256",
          "CmdLine": "DACFramework.msi"
        }
      }
    ]
  }
}
```

### Example 2
The following example defines "AzureRM" as a software:
* that must execute "Install-Module AzureRM -Force -AllowClobber -RequiredVersion 6.8.1" in a Powershell session
* should create/set an environmental variable called "AzurePS" set to "6.8.1"

```json
{
  "AzureRM": {
    "PSLine": "Install-Module AzureRM -Force -AllowClobber -RequiredVersion 6.8.1",
    "EnvironmentalVariables": [
      {
        "Name": "AzurePS",
        "Value": "6.8.1"
      }
    ]
  }
}
```
