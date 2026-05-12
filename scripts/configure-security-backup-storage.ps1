$resourceGroup = "RG-Avdija-Mahmutovic-a632c3-DotNetCloudDeveloper-VT-Mars-Goteborg"
$webAppName = "notes-api-49166"
$storageAccountName = "stnotes49166"
$allowedIp = "88.131.7.250/32"

$backupContainerName = "appservice-backups"
$logsContainerName = "notesapi-logs"

Write-Host "Creating storage containers..."
az storage container create `
  --name $backupContainerName `
  --account-name $storageAccountName `
  --auth-mode login

az storage container create `
  --name $logsContainerName `
  --account-name $storageAccountName `
  --auth-mode login

Write-Host "Creating sample log file..."
"Sample log file for Azure App Service Lab - created by Azure CLI script." | Out-File -FilePath ".\sample-log.txt" -Encoding utf8

Write-Host "Uploading sample log file to storage..."
az storage blob upload `
  --account-name $storageAccountName `
  --container-name $logsContainerName `
  --name "sample-log.txt" `
  --file ".\sample-log.txt" `
  --overwrite true `
  --auth-mode login

Write-Host "Adding IP restriction..."
az webapp config access-restriction add `
  --resource-group $resourceGroup `
  --name $webAppName `
  --rule-name "AllowMyPublicIP" `
  --action Allow `
  --ip-address $allowedIp `
  --priority 100

Write-Host "Getting storage connection string..."
$storageConnectionString = az storage account show-connection-string `
  --resource-group $resourceGroup `
  --name $storageAccountName `
  --query connectionString `
  --output tsv

Write-Host "Creating daily backup schedule..."
az webapp config backup update `
  --resource-group $resourceGroup `
  --webapp-name $webAppName `
  --container-url $storageConnectionString `
  --frequency 1d `
  --retain-one true `
  --retention 7

Write-Host "DONE"
Write-Host "Created containers: $backupContainerName and $logsContainerName"
Write-Host "Added IP restriction for: $allowedIp"
Write-Host "Configured daily backup with 7 days retention"