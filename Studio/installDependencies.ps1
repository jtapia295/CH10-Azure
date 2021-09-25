# TODO: Install Server Dependencies

#------Refresh Env Variables
RefreshEnv.cmd
refreshenv

#------Add Web-Server Role to VM and include IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools

#------Choco allow global confirmation
choco feature enable -n allowGlobalConfirmation

#------Install dotnet windowshosting
choco install dotnetcore-windowshosting

#------Restart services for IIS
net stop WAS /y
net start W3SVC

#------Install Dotnet-SDK
choco install dotnetcore-sdk

#------Install Git
choco install git

#------Install MySQL
choco install MySQL
choco install mysql-cli
