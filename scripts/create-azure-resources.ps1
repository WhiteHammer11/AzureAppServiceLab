# ==============================
# Azure App Service Lab
# Uses existing school resource group
# ==============================

$random = Get-Random -Minimum 10000 -Maximum 99999

$resourceGroup = "RG-Avdija-Mahmutovic-a632c3-DotNetCloudDeveloper-VT-Mars-Goteborg"
$location = "swedencentral"

$appServicePlan = "asp-appservice-lab-$random"
$webAppName = "notes-api-$random"

$sqlServerName = "sqlnotes$random"
$sqlDatabaseName = "NotesDb"
$sqlAdminUser = "sqladminuser"
$sqlAdminPassword = "ChangeThisPassword123!"

$appInsightsName = "appi-notes-api-$random"
$storageAccountName = "stnotes$random"
$keyVaultName = "kv-notes-$random"

Write-Host "Using existing resource group: $resourceGroup"

Write-Host "Creating App Service Plan..."
az appservice plan create `
  --name $appServicePlan `
  --resource-group $resourceGroup `
  --location $location `
  --sku B1 `
  --is-linux

Write-Host "Creating Web App..."
az webapp create `
  --name $webAppName `
  --resource-group $resourceGroup `
  --plan $appServicePlan `
  --runtime "DOTNETCORE:8.0"

Write-Host "Enabling HTTPS only..."
az webapp update `
  --name $webAppName `
  --resource-group $resourceGroup `
  --https-only true

Write-Host "Creating Application Insights..."
az monitor app-insights component create `
  --app $appInsightsName `
  --location $location `
  --resource-group $resourceGroup `
  --application-type web

$appInsightsConnectionString = az monitor app-insights component show `
  --app $appInsightsName `
  --resource-group $resourceGroup `
  --query connectionString `
  --output tsv

Write-Host "Creating Azure SQL Server..."
az sql server create `
  --name $sqlServerName `
  --resource-group $resourceGroup `
  --location $location `
  --admin-user $sqlAdminUser `
  --admin-password $sqlAdminPassword

Write-Host "Creating Azure SQL Database..."
az sql db create `
  --resource-group $resourceGroup `
  --server $sqlServerName `
  --name $sqlDatabaseName `
  --service-objective Basic

Write-Host "Allowing Azure services to access SQL Server..."
az sql server firewall-rule create `
  --resource-group $resourceGroup `
  --server $sqlServerName `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

$sqlConnectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Initial Catalog=$sqlDatabaseName;Persist Security Info=False;User ID=$sqlAdminUser;Password=$sqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Creating Storage Account..."
az storage account create `
  --name $storageAccountName `
  --resource-group $resourceGroup `
  --location $location `
  --sku Standard_LRS

Write-Host "Creating Key Vault..."
az keyvault create `
  --name $keyVaultName `
  --resource-group $resourceGroup `
  --location $location

Write-Host "Adding SQL connection string to Key Vault..."
az keyvault secret set `
  --vault-name $keyVaultName `
  --name "SqlConnectionString" `
  --value $sqlConnectionString

Write-Host "Enabling managed identity on Web App..."
$principalId = az webapp identity assign `
  --name $webAppName `
  --resource-group $resourceGroup `
  --query principalId `
  --output tsv

Write-Host "Giving Web App access to Key Vault secrets..."
az keyvault set-policy `
  --name $keyVaultName `
  --object-id $principalId `
  --secret-permissions get list

Write-Host "Adding app settings..."
az webapp config appsettings set `
  --name $webAppName `
  --resource-group $resourceGroup `
  --settings `
    KeyVaultUrl="https://$keyVaultName.vault.azure.net/" `
    APPLICATIONINSIGHTS_CONNECTION_STRING="$appInsightsConnectionString"

Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "Add your own IP restriction manually later if needed."

Write-Host ""
Write-Host "DONE"
Write-Host "Web App: https://$webAppName.azurewebsites.net"
Write-Host "Resource Group: $resourceGroup"
Write-Host "SQL Server: $sqlServerName"
Write-Host "Key Vault: $keyVaultName"
Write-Host "Storage Account: $storageAccountName"