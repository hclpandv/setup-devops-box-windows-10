#---------------------------------------------------------------------
# TO DO : Install wsl, wsl-ubuntu-1804
#         Install git within wsl-ubuntu
#         Clone the wsl provision repository
#         Provision wsl using ansible playbook
#         Provision Windows Box using win_playbook
#---------------------------------------------------------------------
#---------------
#---- Variables
#---------------
[string]$ScriptDir = Split-Path $MyInvocation.MyCommand.path
[string]$LogDir = "$env:USERPROFILE\ScriptLogs"
[string]$LogFile = "$LogDir\SetupDevOpsBoxWin10.ps1.log"
[Security.Principal.WindowsIdentity]$CurrentProcessToken = [Security.Principal.WindowsIdentity]::GetCurrent()
[boolean]$IsAdmin = [boolean]($CurrentProcessToken.Groups -contains [Security.Principal.SecurityIdentifier]'S-1-5-32-544')
[psobject]$envOS = Get-WmiObject -Class 'Win32_OperatingSystem' -ErrorAction 'SilentlyContinue'
[string]$envOSName = $envOS.Caption.Trim()
[boolean]$Is64Bit = [boolean]((Get-WmiObject -Class 'Win32_Processor' -ErrorAction 'SilentlyContinue' | Where-Object { $_.DeviceID -eq 'CPU0' } | Select-Object -ExpandProperty 'AddressWidth') -eq 64)
[boolean]$ChocoInstalled = [boolean](Get-Command choco.exe -ErrorAction SilentlyContinue)

$PreReqMsg = @"
    Pre-Requisite for this setup
    ----------------------------
    * Windows 10 x64 OS
    * PowerShell v5 or Above
    * Adminstrative access to workstation    

"@

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

Function Enable-UAC { Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA  -Value 1 }

Function Disable-UAC { Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA  -Value 0 }

Function Set-FileExplorerSettings {
    #--- File Explorer Settings ---
    # will Enable ShowHidden Files, Folders, Drives
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 0
    # will Enable file extensions
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0
    # will Enable file extensions
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSuperHidden -Value 1
    # will expand explorer to the actual folder you're in
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
    #adds things back in your left pane like recycle bin
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
    #opens PC to This PC, not quick access
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
    #taskbar where window is open for multi-monitor
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2  
}

#----------------
#---- Main Script
#----------------
Clear-Host

Write-Log "------------------------------------------------------------------"
Write-Log "Starting to Setup Windows Subsystem Linux and Further provisioning"
Write-Log "------------------------------------------------------------------"

# Checking Pre-Requisites
if(($envOSName -like "*Windows 10*") -and ($Is64Bit) -and ($PSVersionTable.PSVersion.Major -ge 5) -and ($IsAdmin)){
    Write-Log "Pre-Requisites are met. Setup process will progress. This process will involve multiple installation, please have patience"
}
else{
    Write-Log "Pre-Requisites are NOT met. Exiting.."
    Write-Host -ForegroundColor DarkCyan -Object $PreReqMsg
    throw "Existing from the setup process"
    #exit 1
}

# Disable UAC
Write-Log "Disable UAC"
Disable-UAC

# Set file explorer settings for DevBox
Write-Log "Set File Explorer settings"
Set-FileExplorerSettings

# Installing chocolatey
if($ChocoInstalled){
    Write-Log "chocolatey is already installed on your workstation"
}
else{
    Write-Log "Installing chocolatey" 
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
}

# Refresh Environment (Script comes with chocolatey installation)
Write-Log "Refreshing to environment to load new env varaibles"
RefreshEnv

# Install WSL
Write-Log "Install Windows Subsystem Linux"
choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"

# Install Ubuntu Distro
Write-Log "Install Ubuntu 1804 Distribution"
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

# Run the distro once and have it install locally with root user, unset password
RefreshEnv
Ubuntu1804 install --root
Ubuntu1804 run apt update
Ubuntu1804 run apt upgrade -y
ubuntu1804 config --default-user root
$ubuntu_scriptdir =  $(ubuntu1804 run pwd)

# Install python
ubuntu1804 run apt-get install python -y

# Add Ansible ppa
ubuntu1804 run add-apt-repository ppa:ansible/ansible -y

# Update apt cache
ubuntu1804 run apt-get update -y

# Install Ansible
ubuntu1804 run apt-get install ansible -y

# Copy wsl-provisoning folder in Distro (Must be git cloned in advance)
# git clone https://vpandey6@bitbucket.org/patpol/wls_provisioning.git
if(Test-Path $ScriptDir\wls_provisioning){
   ubuntu1804.exe run cp -R $ubuntu_scriptdir/wls_provisioning ~    
}
else{ Write-Log "wsl_provisioing folder not found on the script root, please validate"}

# Enable UAC
Enable-UAC


