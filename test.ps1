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

cd $ScriptDir
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

# Play the ansible playbook
ubuntu1804 run ansible-playbook -i ./wls_provisioning/hosts ./wls_provisioning/playbook.yml