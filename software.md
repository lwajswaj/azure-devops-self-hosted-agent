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
| Arguments | string | Not required | Arguments to be used with CmdLine. Keep in mind you can't user PSLine and Arguments. Arguments is strictly used for CmdLine. Keep in mind the config file runs in an ELEVATED PROMPT so you don't have to worry about elevated permissions |
| AddToPath | string | Not required | Value to be added to Windows PATH environmental variable, some installers like python's prependpath will do this for you if you set up the arguments correctly. |
| EnvironmentalVariables | Array of two pair strings | Not required | Must have a name and value, see below for example |
| PreRequirements | package | Not required | A nested package with the above specifications like this. PreRequirements will always get installed first |


### How to find the hash example for python 3.7.4.exe:
Open Powershell

    ```
    powershell
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


## Example

```json
{
"Python":{
	"Uri": "https://www.python.org/ftp/python/3.7.4/python-3.7.4-amd64.exe",
	"Hash": "BAB92F987320975C7826171A072BFD64F8F0941AAF2CDEBA6924B7025C9968A3",
	"HashType": "SHA256",
	"CmdLine": "python-3.7.4-amd64.exe",
	"Arguments": "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0",
	"EnvironmentalVariables": [{
        "Name": "python",
        "Value": "C:\\Program Files\\Python37\\python.exe"
      }]
    }	
}
```

## Warning
Keep in mind that just because you declare your enviorment variables that they might not actually exist in devops. Always check your 
CmdLine and Arguments to ensure that you are actually installing the package.
