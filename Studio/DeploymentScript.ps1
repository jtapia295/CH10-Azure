. .\serverSetupAzure.ps1

az vm run-command invoke --command-id RunPowerShellScript --scripts "@installChoco.ps1"

az vm stop
az vm start

az vm run-command invoke --command-id RunPowerShellScript --scripts "@installDependencies.ps1"

# TODO: Clone and push new public ip and KV name to appsetting.json
#-----Udpate Appsettings
git clone "https://github.com/jtapia295/coding-events-api" "./coding-events-api"
Set-Location "./coding-events-api"
git checkout 3-aadb2c
Set-Location "./CodingEventsAPI"
$object = Get-Content "./appsettings.json" | ConvertFrom-Json
$object.ServerOrigin = "https://$vmPublicIp"
$object.KeyVaultName = "$kvName"
$object | ConvertTo-Json | out-file "appsettings.json" -Force
Set-Location ..
git add .
git commit -m "CH10-Studio: Successfully updated appsettings to reflect current vm config."
git push origin 3-aadb2c

Set-Location ../

az vm stop
az vm start

az vm run-command invoke --command-id RunPowerShellScript --scripts "@setupserverVM.ps1"




