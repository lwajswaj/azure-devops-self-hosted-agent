Param(
  [Parameter(Mandatory)]
  [string] $TeamAccount,
  [string] $PoolName = "default",
  [Parameter(Mandatory)]
  [string] $PATToken
)

DynamicParam {
  if(Test-Path -Path .\software.json) {
    $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

    Get-Content -Path .\software.json | ConvertFrom-Json | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty" -and $_.Name -ne "VSTS"} | Select-Object -ExpandProperty Name | ForEach-Object -Process {
      $newParamAttributes = New-Object System.Management.Automation.ParameterAttribute
      $newParamAttributes.Mandatory = $false
      $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
      $attributeCollection.Add($newParamAttributes)
      $newParam = New-Object System.Management.Automation.RuntimeDefinedParameter($_, [Switch], $attributeCollection)
      $paramDictionary.Add($_, $newParam)
    }

    return $paramDictionary
  }
}

Process {
  $PackagesPath = "C:\Packages\AzureDevOpsAgent"

  Function Add-ToPath{
    Param(
      [Parameter(Mandatory)]
      [string]$Value
    )

    $Path = [System.Environment]::GetEnvironmentVariable("PATH","Machine")
    $Path += ";$Value"
    [System.Environment]::SetEnvironmentVariable("PATH",$Path,"Machine")
  }

  Function Download-Software {
    Param(
      [Parameter(Mandatory)]
      [string] $Uri,
      [String] $Hash,
      [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512")]
      [String] $HashType = "SHA256",
      [String] $DestinationPath = ".\"
    )

    [bool]$ShouldDownload = $true

    Write-Host "Uri is now = $Uri"
    Write-Host "Hash is now = $Hash"
    Write-Host "HashType is now = $HashType"
    Write-Host "DestinationPath is now = $DestinationPath"

    $FileName = $Uri.SubString($Uri.LastIndexOf('/') + 1)
    if($FileName.Contains('?')){
      $FileName = $FileName.SubString(0,$OutFile.IndexOf('?'))
    }
    Write-Host "FileName is now = $FileName"

    Write-Host "Checking if destination path exists"
    If(!(Test-Path -Path $DestinationPath)) {
      Write-Host "Not Found. Creating it..."
      New-Item -Path $DestinationPath -ItemType Directory | Out-Null
    }

    $OutFile = "{0}\{1}" -f (Resolve-Path -Path $DestinationPath).Path, $FileName
    Write-Host "OutFile is now = $OutFile"

    if(Test-Path $OutFile) {
      Write-Host "There's already a file with the same name at destination"

      if($Hash) {
        if((Get-FileHash -Path $OutFile -Algorithm $HashType).Hash -eq $Hash) {
          Write-Host "Existing file matches expected hash, skipping download"
          $ShouldDownload = $false
        }
      }
      else {
        Write-Host "Hash value not provided. Continuing with current downloaded files"
        $ShouldDownload = $false
      }
    }
    
    if($ShouldDownload){
      Write-Host "Proceeding to download..."
      Write-Host "Source = $Uri"
      Write-Host "Destination = $OutFile"
      $webClient = New-Object System.Net.WebClient
      $webClient.DownloadFile($Uri, $OutFile)
      Write-Host "Download completed!"
    }

    if($Hash) {
      if((Get-FileHash -Path $OutFile -Algorithm $HashType).Hash -ne $Hash) {
        throw "File hash mismatch"
      }
    }

    if($FileName -like "*.zip") {
      Write-Host "Downloaded file is a ZIP file, proceeding to unzip it"
      $DestinationPath = "{0}\{1}" -f $DestinationPath,$FileName.SubString(0,$FileName.LastIndexOf("."))
      Write-Host "DestinationPath is now = $DestinationPath"

      Expand-Archive -Path $OutFile -DestinationPath $DestinationPath -Force | Out-Null
    }

    return $DestinationPath
  }

  Function Install-Component{
    Param(
      [System.Object] $Component,
      [string] $Arguments
    )

    If($Component.PreRequirements) {
      $PreReqs = $Component.PreRequirements | Get-Member | Where-Object -Property MemberType -eq -Value "NoteProperty" | Select-Object -ExpandProperty Name

      ForEach($PreReq In $PreReqs) {
        Write-Host "Pre-Requirement Found: $PreReq"
        Install-Component -Component $Component.PreRequirements.$PreReq
      }
    }

    if($Component.Uri) {
      $WorkingDir = Download-Software -Uri $Component.Uri -Hash $Component.Hash -HashType $Component.HashType -DestinationPath $PackagesPath
      Write-Host "WorkingDir is now = $WorkingDir"
    }
    else {
      $WorkingDir = ""
    }

    if($Component.Cmdline) {
      if($Component.CmdLine.EndsWith(".msi")) {
        $FilePath = "$Env:SYSTEMROOT\System32\msiexec.exe"
        if(!$Arguments) {
          $Arguments = ("/i ""{0}\{1}"" /qn ALLUSERS=1 REBOOT=ReallySuppress" -f $WorkingDir,$Component.CmdLine)
        }
      }
      else {
        $FilePath = "{0}\{1}" -f $WorkingDir,$Component.CmdLine
        if(!$Arguments) {
          $Arguments = $Component.Arguments
        }
      }
      
      Write-Host "FilePath is now = $FilePath"
      Write-Host "Arguments is now = $Arguments"
      Write-Host "Executing..."
      $Result = Start-Process -FilePath $FilePath -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
      Write-Host ("Exit code: {0}" -f $Result.ExitCode)
    }

    if($Component.PSLine) {
      Write-Host "Powershell Line Statement Found"
      Write-Host $Component.PSLine
      Invoke-Expression $Component.PSLine
    }

    if($Component.AddToPath) {
      Write-Host "AddToPath directive found"
      Write-Host ("Adding '{0}' to PATH" -f $Component.AddToPath)
      Add-ToPath -Value $Component.AddToPath
    }

    if($Component.EnvironmentalVariables) {
      Write-Host "Environmental Variables directive found"
      ForEach($EnvVar In $Component.EnvironmentalVariables) {
        Write-Host ("Setting Environmental Variable '{0}' to '{1}'" -f $EnvVar.Name, $EnvVar.Value)
        [System.Environment]::SetEnvironmentVariable($EnvVar.Name,$EnvVar.Value,"Machine")
      }
    }
  }

  $Software = $null

  if(Test-Path -Path .\software.json) {
    $Software = Get-Content -Path .\software.json | ConvertFrom-Json
  }
  else {
    throw ("software.json cannot be found at '{0}'" -f (Resolve-Path -Path .\).Path)
  }

  If(-not (get-PackageProvider | ? {$_.Name -eq "NuGet" -and $_.Version -gt "2.8.5.201"})) {
    Write-Host "Installing NuGet Package Provider"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
  }

  Write-Host "Setting PSGallery as a trusted source"
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null

  Write-Host "Forcing Powershell to use TLS 1.2 for Network Communication"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  ForEach($Param In $PsBoundParameters.Keys) {
    if($Software.$Param) {
      Write-Host "################ Begin $Param ################"
      Install-Component -Component $Software.$Param
      Write-Host "################ End $Param ################"
      Write-Host ""
    }
  }

  Write-Host "################ Begin Azure DevOps Agent ################"
  Install-Component -Component $Software.vsts -Arguments "--unattended --url https://$TeamAccount.visualstudio.com --auth pat --token $PATToken --pool ""$PoolName"" --agent $ENV:COMPUTERNAME --work D:\agent_work --runAsService --windowsLogonAccount ""NT AUTHORITY\SYSTEM"""
  Write-Host "################ End Azure DevOps Agent ################"
}