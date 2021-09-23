# TODO: set variables
$studentName = "jose"
$rgName = "jose-ch9-wt-rg-2"
$vmName = "jose-ch9-wt-vm-2"
$vmSize = "Standard_B2s"
$vmImage = az vm image list --query "[? contains(urn,'Ubuntu')] | [0].urn"
$vmAdminUsername = "student"
$kvName = "$studentName-lc0921-ps-kv-2"
$kvSecretName = "ConnectionStrings--Default"
$kvSecretValue = "server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode"

# TODO:Set-Default Location
az configure --defaults location=eastus 
# TODO: provision RG
az group create -n $rgName 
az configure --defaults group="$rgName"

# TODO: provision VM
az vm create --name $vmName --size $vmSize --image $vmImage --admin-username $vmAdminUsername --assign-identity --generate-ssh-keys
az configure --defaults vm=$vmName 

# TODO: capture the VM systemAssignedIdentity
$vmObjectId = $(az vm show --query "identity.principalId")

# TODO:Get VM Public IP
$vmPublicIp = az vm list-ip-addresses -n $vmName --query "[].virtualMachine.network.publicIpAddresses | [].ipAddress" | ConvertFrom-Json

# TODO: open vm port 443
az vm open-port --name $vmName --port 443 


# TODO: provision KV
az keyvault create -n $kvName --enable-soft-delete false --enabled-for-deployment true

# TODO: Clone and push new public ip and KV name to appsetting.json 

git clone "https://github.com/jtapia295/coding-events-api" "./coding-events-api"
cd "./coding-events-api" 
git checkout 3-aadb2c
cd "./CodingEventsAPI"
$object = Get-Content "./appsettings.json" | ConvertFrom-Json
$object.ServerOrigin = "https://$vmPublicIp"
$object.KeyVaultName = "$kvName"
$object | ConvertTo-Json | out-file "appsettings.json" -Force
cd ..
git add . 
git commit -m "Successfully updated appsettings to reflect current vm config."
git push origin 3-aadb2c

cd ../ 

# TODO: create KV secret (database connection string)
az keyvault secret set --vault-name $kvName -n $kvSecretName --value $kvSecretValue

# TODO: set KV access-policy (using the vm ``systemAssignedIdentity``)
"az keyvault set-policy -n $kvName --object-id $vmObjectId --secret-permissions get list"

az vm run-command invoke --command-id RunShellScript --scripts @vm-configuration-scripts/1configure-vm.sh

az vm run-command invoke --command-id RunShellScript --scripts @vm-configuration-scripts/2configure-ssl.sh

az vm run-command invoke --command-id RunShellScript --scripts @deliver-deploy.sh


# TODO: print VM public IP address to STDOUT or save it as a file
$vmPublicIp | Add-Content "vm-configuration.txt"

echo "Your VM Public IP is $(cat vm-configuration.txt)"
echo "Access Link 'https://$(cat vm-configuration.txt)" 

