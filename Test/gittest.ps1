git clone "https://github.com/jtapia295/coding-events-api" "./coding-events-api"

cd "./coding-events-api"

git checkout "3-aadb2c" 

cd "./CodingEventsAPI"

$object = Get-Content "./appsettings.json" | ConvertFrom-Json 

$object.ServerOrigin = "Test" 
$object.KeyVaultName = "Test"

$object | ConvertTo-Json | Out-File "appsettings.json" -Force
