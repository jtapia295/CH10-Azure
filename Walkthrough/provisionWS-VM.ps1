# TODO: set variables
$studentName = "jose"
$rgName = "$(az group create -n "$studentName-ws-st" --query "name")"
$vmName = "$studentName-ch10-wt-vm"
$vmSize = "Standard_B2s"
$vmImage = az vm image list --query "[? contains(urn,'Windows') && contains(urn,'2019')] | [0].urn"
$vmAdminUsername = "student"
$vmAdminPass = "LaunchCode-@zure1"
$kvName = "$studentName-lc0921-ps-kv-2"
$kvSecretName = "ConnectionStrings--Default"
$kvSecretValue = "server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode"

# TODO:Set-Default Location
az configure --defaults location=eastus 
# TODO: provision RG
az configure --defaults group="$rgName"

# TODO: provision VM
az vm create --name $vmName --size $vmSize --image $vmImage --admin-username $vmAdminUsername --admin-password $vmAdminPass --assign-identity
az configure --defaults vm=$vmName 

# TODO: capture the VM systemAssignedIdentity
$vmObjectId = $(az vm show --query "identity.principalId")

# TODO:Get VM Public IP
$vmPublicIp = az vm list-ip-addresses -n $vmName --query "[].virtualMachine.network.publicIpAddresses | [].ipAddress" | ConvertFrom-Json


# TODO: print VM public Ip address to STDOUT or save it as a file
echo "Your IP:$vmPublicIp", "Your ObjectId:$vmObjectId" | Add-Content "vm-configuration.txt"

echo "Your VM Public IP is $(cat vm-configuration.txt)"
echo "Access Link 'https://$(cat vm-configuration.txt)" 

# TODO: RDP into VM 
mstsc /v:$vmPublicIp
