# TODO: set variables
$studentName = "jose"
$rgName = "jose-ch10-studio-rg"
$vmName = "jose-studio-vm"
$vmSize = "Standard_B2s"
$vmImage = az vm image list --query "[? contains(urn,'Windows') && contains(urn,'2019')] | [0].urn"
$vmAdminUsername = "student"
$vmAdminPass = "LaunchCode-@zure1"
$kvName = "$studentName-ch10-studio-kv"
$kvSecretName = "ConnectionStrings--Default"
$kvSecretValue = "server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode"

# TODO:Set-Default Location
az configure --defaults location=eastus
 
# TODO: provision RG
az group create -n $rgName 
az configure --defaults group="$rgName"

# TODO: provision VM
az vm create --name $vmName --size $vmSize --image $vmImage --admin-username $vmAdminUsername --admin-password $vmAdminPass --assign-identity

az configure --defaults vm=$vmName 

# TODO: capture the VM systemAssignedIdentity
$vmObjectId = $(az vm show --query "identity.principalId")

# TODO:Get VM Public IP
$vmPublicIp = az vm list-ip-addresses -n $vmName --query "[].virtualMachine.network.publicIpAddresses | [].ipAddress" | ConvertFrom-Json

# TODO: open vm port 443
az vm open-port --name $vmName --port 443

# TODO: provision KV
az keyvault create -n $kvName --enabled-for-deployment true

# TODO: create KV secret (database connection string)
az keyvault secret set --vault-name $kvName -n $kvSecretName --value $kvSecretValue

# TODO: set KV access-policy (using the vm ``systemAssignedIdentity``)
az keyvault set-policy -n $kvName --object-id $vmObjectId --secret-permissions get list

# TODO: print VM public IP address to STDOUT or save it as a file
Write-Output "Your Ip: $vmPublicIp","Your ObjectID: $vmObjectId" | Add-Content "vm-configuration.txt"


