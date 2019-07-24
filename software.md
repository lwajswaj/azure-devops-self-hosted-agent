# Installing software duging self-hosted agent 
This file will explain the formatting of the software.json file and how to add additional software.

## Formatting
In short, the software.json file is a giant hash-table of packages that will be called in the configuration file. Below is a quick example of how the file looks 

```json
{
  "<package>": {
  	"<specifications>"
  },
  
  "<another-package>": {
  	"<specifications>"
  }
}
```
See azuredeploy.md to see how these packages are utilized. 

#### Specification Values
The following values are all possible options

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| Uri | string | Not required | Url of package to download|
| Hash | string | Not required | Hash value of the return item of the url (exe, msi, zip),  after table there is a step to get hash value |
| HashType | string | Not required  | Supported values: MD5, SHA, SHA256, SHA384, SHA512. Just use SHA256 because every other package does in this file uses SHA256, its just easier to read. |
| PSLine | string | Not required| Powershell line to be executed, make sure to write all arguments for a powershell line on the PSLine |
| CmdLine | string | Not required | Command to be executed  |
| Arguments | string | Not required | Arguments to be used with CmdLine. Keep in mind you can't user PSLine and Arguments. Arguments is strictly used for CmdLine. |
| AddToPath | string | Not required | Value to be added to Windows PATH environmental variable, some installers like python's prependpath will do this for you if you set up the arguments correctly. |
| EnvironmentalVariables | Array of two pair strings | Not required | Must have a name and value, see below for example |
| PreRequirements | package | Not required | a nested package with the above specifications like this. PreRequirements will always get installed first |


### How to find the hash example for python 3.7.4.exe:
    ```ps
    Get-FileHash .\python-3.7.4-amd64.exe -Algorithm SHA256
    ```
Value: BAB92F987320975C7826171A072BFD64F8F0941AAF2CDEBA6924B7025C9968A3

### Example enviornment variables in python
```json
  "EnviornmentalVariables : [
  {
    "Name": "python",
    "Value": "C:\\Program Files\\Python37\\python.exe"
   
  },
  
  {
  "Name": "<another python enviornment>",
  "Value": "<path to that spot>"
  }
  ]
```


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
