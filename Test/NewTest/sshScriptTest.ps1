az vm start
$vmIp = az vm list-ip-addresses --query "[].virtualMachine.network.publicIpAddresses | [0].ipAddress" | ConvertFrom-Json
$vmIp | Add-Content .\vmip.txt
ssh student@$vmip
