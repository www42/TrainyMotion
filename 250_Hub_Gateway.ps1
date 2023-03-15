# ------------------------------------------------------------------------------------
# Hub infrastructure in a hub-spoke topology.
# This deploys
#    * hub virtual network
#    * virtual gateway
# ------------------------------------------------------------------------------------
$templateFile = 'NetworkHub/main.bicep'
$templateParams = @{
    location = 'westeurope'
    resourceGroupName = 'RG-SharedNetworkResources'
    vnetName = 'VNet-Hub'
    gatewayName = 'VPN-GW'
}

New-AzSubscriptionDeployment -Name 'NetworkHub' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $templateParams.location -ResourceGroupName $templateParams.resourceGroupName

# Virtual Gateway Certificate
# ---------------------------
# Requires Windows PowerShell 5.1  (wegen cert:)
$rgName = $templateParams.resourceGroupName
$gatewayName = $templateParams.gatewayName
$vnetName = $templateParams.vnetName
$rootCertificateName = 'trainymotionRootCertificate'
$clientCertificateName = 'trainymotionVpnClientCertificate'
$pfxPassword = 'Pa55w.rd1234'

# 1. Root certificate
# -------------------
$rootCertificate = New-SelfSignedCertificate `
    -FriendlyName $rootCertificateName `
    -Subject "CN=$rootCertificateName" `
    -Type Custom `
    -KeySpec Signature `
    -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 `
    -KeyLength 2048 `
    -KeyUsageProperty Sign `
    -KeyUsage CertSign `
    -CertStoreLocation 'Cert:\CurrentUser\My'

dir Cert:\CurrentUser\My

# Public certificate data to be uploaded to gateway
$rootCertPublicData = [System.Convert]::ToBase64String($rootCertificate.RawData)

# There are several ways to upload
#   a) Upload by CLI
az network vnet-gateway root-cert create `
    --name $rootCertificateName `
    --public-cert-data $rootCertPublicData `
    --gateway-name $gatewayName `
    --resource-group $rgName

#   b) Copy/paste to ARM template, copy/paste to portal
$rootCertPublicData | clip 

# Let's export Root certificate
$password = ConvertTo-SecureString -String $PfxPassword -AsPlainText -Force
$rootCertificate | Export-PfxCertificate -FilePath ./$rootCertificateName.pfx -Password $password

# Remove root certificate (We have a pfx exported) 
Remove-Item -Path $rootCertificate.PSPath

# 2. Client Certificate
# ---------------------
# Import Root certificate
$password = ConvertTo-SecureString -String $PfxPassword -AsPlainText -Force
$rootCertificate = Import-PfxCertificate -FilePath ./$RootCertificateName.pfx -CertStoreLocation 'Cert:\CurrentUser\My' -Exportable -Password $password

# Create client certificate
$clientCertificate = New-SelfSignedCertificate `
    -FriendlyName $clientCertificateName `
    -Subject "CN=$clientCertificateName" `
    -Type Custom `
    -KeySpec Signature `
    -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 `
    -KeyLength 2048 `
    -Signer $rootCertificate `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") `
    -CertStoreLocation 'Cert:\CurrentUser\My'
    
Get-ChildItem Cert:\CurrentUser\My | 
    where {$_.Subject -eq "CN=$rootCertificateName" -or $_.Subject -eq "CN=$clientCertificateName"} | 
    ft Subject, Issuer, Thumbprint

# 3. VPN client
# --------------
# Download VPN client
$uri = az network vnet-gateway vpn-client generate `
    --processor-architecture Amd64 `
    --name $gatewayName --resource-group $rgName `
    --output tsv

$vpnZipPath="$env:HOMEPATH\Downloads"

Invoke-RestMethod -Uri $uri -OutFile $vpnZipPath\VpnClient.zip

Expand-Archive -Path $vpnZipPath\VpnClient.zip -DestinationPath $vpnZipPath\VpnClient

# Install VPN client manually
& $vpnZipPath\VpnClient\WindowsAmd64\VpnClientSetupAmd64.exe

# Connect
cmd.exe /C "start ms-settings:network-vpn"

# Test connectivity
Get-NetIPConfiguration | where InterfaceAlias -eq $vnetName
Test-NetConnection 10.0.0.4 -Traceroute
Test-NetConnection 10.0.1.4 -Traceroute
Test-NetConnection 10.0.4.4 -Traceroute


# 4. Clean up
# -----------
Remove-Item -Path $RootCertificate.PSPath
Remove-Item -Path $ClientCertificate.PSPath