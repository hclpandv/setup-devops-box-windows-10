#---------------------------------------------------------------------
# TO DO : Install Chcolatey and then setup Winodows 10 x64 Workstation
#         Software Expected : Vagrant, Oracle VirtualBox, Git
#         Will Try to write DSC and Ansible playbook for the same
#---------------------------------------------------------------------

#---------------
#---- Variables
#---------------
[string]$LogDir = "$env:USERPROFILE\ScriptLogs"
[string]$LogFile = "$LogDir\SetupDevOpsBoxWin10.ps1.log"
[psobject]$envOS = Get-WmiObject -Class 'Win32_OperatingSystem' -ErrorAction 'SilentlyContinue'
[string]$envOSName = $envOS.Caption.Trim()
[boolean]$Is64Bit = [boolean]((Get-WmiObject -Class 'Win32_Processor' -ErrorAction 'SilentlyContinue' | Where-Object { $_.DeviceID -eq 'CPU0' } | Select-Object -ExpandProperty 'AddressWidth') -eq 64)
[boolean]$ChocoInstalled = [boolean](Get-Command choco.exe -ErrorAction SilentlyContinue)

#--------------
#---- Functions
#--------------
Function Write-Log {
    Param (
        [Parameter(Mandatory = $True, Position = 0)] [String] $Message
    )    
    # Create log directory when needed
    If ((Test-Path -Path $LogDir) -eq $False) {
        New-Item $LogDir -Type Directory | Out-Null
    }
    $TimeStamp = "[" + (Get-Date -Format dd-MM-yy) + "," + (Get-Date -Format HH:mm:ss) + "] "
    $Log = $TimeStamp + $Message 
    # Write to screen
    Write-Host -Object $Message   
    # Write to log file
    Add-Content -Path $LogFile -Value $Log
}

#----------------
#---- Main Script
#----------------
Write-Log "--------------------------------------------------"
Write-Log "Starting to Setup Windows 10 as DevOps Workstation"

# Checking Pre-Requisites
if(($envOSName -like "*Windows 10*") -and ($Is64Bit) -and ($PSVersionTable.PSVersion.Major -ge 5)){
    Write-Log "Pre-Requisites are met. Setup process will progress. This process will involve multiple installation, please have patience"
}
else{
    Write-Log "Pre-Requisites are met. Setup process will progress. This process will involve multiple installation, please have patience"
    throw "Existing from the setup process"
}


# Installing chocolatey
if($ChocoInstalled){
    Write-Log "chocolatey is already installed on your workstation"
}
else{
    Write-Log "Installing chocolatey" 
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
}

# Installation of packages from the chocolatey repository
$Packages = @(
              'git'
              'virtualbox'
              'vagrant'
              'insomnia-rest-api-client'

)

ForEach ($PackageName in $Packages){
    
    choco install $PackageName -y
}


<#

# Installing git
choco install git
# Installing Oracle virtBox
choco install virtualbox
# Installing vagrant
chco install vagrant
# Installing ConEmu
choco install conemu
# Installing Insomnia rest api client
choco install insomnia-rest-api-client

#>

