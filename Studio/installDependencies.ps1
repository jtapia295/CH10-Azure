# TODO: Install Server Dependencies

#------Add Web-Server Role to VM and include IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools

#------Install dotnet windowshosting
choco install dotnetcore-windowshosting -y

#------Restart services for IIS
net stop WAS /y
net start W3SVC

#------Install Dotnet-SDK
choco install dotnetcore-sdk -y

#------Install Git
choco install git -y

#------Install MySQL
choco install MySQL -y


