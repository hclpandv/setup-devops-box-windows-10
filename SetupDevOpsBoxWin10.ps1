#---------------------------------------------------------------------
# TO DO : Install Chcolatey and then setup Winodows 10 x64 Workstation
#         Software Expected : Vagrant, Oracle VirtualBox, Git
#         Will Try to write DSC and Ansible playbook for the same
#---------------------------------------------------------------------

#---- Functions

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

#---- Variables
$LogDir = "$env:USERPROFILE"
$LogFile = "$LogDir\SetupDevOpsBoxWin10.ps1.log"

#---- Main Script
Write-Log "Starting to Setup Windows 10 as DevOps Workstation"

Write-Log "Starting to Setup Windows 10 as DevOps Workstation"
