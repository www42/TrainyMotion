# Azure IoT Hub Extension for VS Code
https://marketplace.visualstudio.com/items?itemName=vsciot-vscode.azure-iot-toolkit

# powershell

# IoT Hubs
az iot hub list --query "[].{name:name,resourcegroup:resourcegroup,sku:sku.name,location:location}" --output table 
$iotHubName = "mxhub007"

# Devices
az iot hub device-identity list --hub-name $iotHubName --query "[].{deviceId:deviceId,connectionState:connectionState,authenticationType:authenticationType}" --output table







# Storage Account - IAM - Storage Blob Data Reader
azcopy login
azcopy copy 'https://iot69118.blob.core.windows.net/iotresults2/Hub-s1/02/2022/05/09/20/58.json' ./blob.json

Get-Content ./blob.json | ConvertFrom-Json | ForEach-Object {[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($_.Body)) | ConvertFrom-Json}

Install-Module -Name Microsoft.PowerShell.TextUtility -AllowPrerelease -Force

Get-Content ./blob.json | ConvertFrom-Json | ForEach-Object { ConvertFrom-Base64 $_.Body | ConvertFrom-Json} | 
    Format-Table messageId, `
                 deviceId, `
                 @{n='temperature';e={'{0,11:N1}' -f $_.temperature}}, `
                 @{n='humidity';   e={'{0, 8:N1}' -f $_.humidity}}
               