#-----Refresh Env Vars
RefreshEnv.cmd
refreshenv

# Create Directories
mkdir $env:systemdrive\Users\student\webapp
mkdir $env:systemdrive\Users\student\webapp\coding-events-api
mkdir $env:systemdrive\inetpub\CodingEvents

# TODO: Clone Coding Events API
git clone "https://github.com/jtapia295/coding-events-api" "C:\Users\student\webApp\coding-events-api"
Set-Location C:\Users\student\webapp\coding-events-api
git checkout 3-aadb2c
Set-Location ".\CodingEventsAPI"


# Provision MySql
Write-Output @"
CREATE DATABASE coding_events;
CREATE USER 'coding_events'@'localhost' IDENTIFIED BY 'launchcode';
GRANT ALL PRIVILEGES ON coding_events.* TO 'coding_events'@'localhost';
FLUSH PRIVILEGES;
"@ | Add-Content C:\Users\student\setup.sql

mysql -u root -e 'source C:\Users\student\setup.sql'

$siteName = "Coding Events API"
#------Publish the site in IIS directory
dotnet publish -c Release -r win-x64 -o $env:systemdrive\inetpub\CodingEvents

#-----Store the Thumbprint Require in Variable
$CertThumbprint = (New-SelfSignedCertificate -CertStoreLocation Cert:LocalMachine\MY  -DnsName (Invoke-RestMethod "http://ipinfo.io/json").ip) | Select-Object -ExpandProperty Thumbprint

#-----Create the site
New-IISSite -Name $siteName -PhysicalPath "$env:systemdrive\inetpub\CodingEvents" -BindingInformation "*:443:" -CertificateThumbPrint $CertThumbprint -CertStoreLocation "Cert:\LocalMachine\MY" -Protocol https 

#------Set SSL Required Attribute
Start-IISCommitDelay
$ConfigSection = Get-IISConfigSection -SectionPath "system.webServer/security/access" -Location $siteName
#to set:
Set-IISConfigAttributeValue -AttributeName sslFlags -AttributeValue Ssl -ConfigElement $ConfigSection
#to read:
Get-IISConfigAttributeValue -ConfigElement $ConfigSection -AttributeName sslFlags

#------Enable HSTS with Redirect Thanks to https://www.server-world.info/en/note?os=Windows_Server_2019&p=iis&f=6
#--- get site collection

$sitesCollection = Get-IISConfigSection -SectionPath "system.applicationHost/sites" | Get-IISConfigCollection

# get web site you'd like to set HSTS
# specify the name of site for "name"="***"
$siteElement = Get-IISConfigCollectionElement -ConfigCollection $sitesCollection -ConfigAttribute @{"name"="$siteName"}

# get setting of HSTS for target site
$hstsElement = Get-IISConfigElement -ConfigElement $siteElement -ChildElementName "hsts"

# enable HSTS for target site
Set-IISConfigAttributeValue -ConfigElement $hstsElement -AttributeName "enabled" -AttributeValue $true

# set [redirectHttpToHttps] of HSTS as enabled
Set-IISConfigAttributeValue -ConfigElement $hstsElement -AttributeName "redirectHttpToHttps" -AttributeValue $true

Stop-IISCommitDelay

#----Start IIS Site
Start-IISSite -Name "$siteName"
