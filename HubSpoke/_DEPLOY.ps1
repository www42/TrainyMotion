# ------------------------------------------------------------------------------------
# Scenario Hub-and-Spoke
# ------------------------------------------------------------------------------------
# This deploys
#    * Hub virtual network
#    * Bastion host
#    * Optional: Virtual gateway 
#                   with certificates
#                   with VPN client Windows
# ------------------------------------------------------------------------------------
# Requires Windows PowerShell 5.1  (due to 'cert:')
# ------------------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription
az login
az account show --query "{name:name,user:user.name,tenant:tenantId,subscription:id}"




# ------------------------------------------------------------------------------------
# DEPLOYMENT
#
$templateFile = 'templates/main.bicep'
$templateParams = @{
    location = 'westeurope'
    resourceGroupName = 'rg-hub'
    vnetName = 'vnet-hub'
    gatewayDeploymentYesNo = $false
    gatewayName = 'vgw-trainymotion'
}
$templateParams['gatewayDeploymentYesNo'] = $true

New-AzSubscriptionDeployment -Name 'Hub-and-Spoke-Scenario' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $templateParams.location -ResourceGroupName $templateParams.resourceGroupName
#
# ------------------------------------------------------------------------------------





# Import Root Certificate (needed to create Client Certificate)
# -------------------------------------------------------------------
dir './RootCertificate.pfx'
$pfxPassword = ''
$password = ConvertTo-SecureString -String $PfxPassword -AsPlainText -Force
$rootCertificate = Import-PfxCertificate -FilePath './RootCertificate.pfx' -CertStoreLocation 'Cert:\CurrentUser\My' -Exportable -Password $password
$rootCertificate | Format-List Thumbprint,FriendlyName,Subject,NotBefore,NotAfter

# Create VPN Client Certificate
# -------------------------------------------------------------------
$friendlyName = 'Trainymotion VPN Client Certificate'
$subject = 'cn=Trainymotion VPN Client'
$clientCertificate = New-SelfSignedCertificate `
    -FriendlyName $friendlyName `
    -Subject $subject `
    -Type Custom `
    -KeySpec Signature `
    -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 `
    -KeyLength 2048 `
    -Signer $rootCertificate `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") `
    -CertStoreLocation 'Cert:\CurrentUser\My'

dir $clientCertificate.PSPath | Format-List FriendlyName,Subject,Issuer,NotBefore,NotAfter

# Download and install VPN Client Software
# -------------------------------------------------------------------
$rgName = $templateParams.resourceGroupName
$gatewayName = $templateParams.gatewayName

$uri = az network vnet-gateway vpn-client generate `
    --processor-architecture Amd64 `
    --name $gatewayName --resource-group $rgName `
    --output tsv

$vpnZipPath = "$env:HOMEPATH\Downloads"
Invoke-RestMethod -Uri $uri -OutFile $vpnZipPath\VpnClient.zip
dir $vpnZipPath\VpnClient.zip
Expand-Archive -Path $vpnZipPath\VpnClient.zip -DestinationPath $vpnZipPath\VpnClient

# Install VPN client manually
& $vpnZipPath\VpnClient\WindowsAmd64\VpnClientSetupAmd64.exe

# Connect
cmd.exe /C "start ms-settings:network-vpn"

# Test connectivity
Get-NetIPConfiguration | Format-Table InterfaceAlias,InterfaceDescription,IPv4Address
Test-NetConnection 10.0.0.4 -Traceroute


# Cleanup
# -------------------------------------------------------------------
Remove-Item -Path $RootCertificate.PSPath
Remove-Item -Path $ClientCertificate.PSPath
dir Cert:/CurrentUser/My
cmd.exe /C "start ms-settings:network-vpn"



# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState
Get-AzSubscriptionDeployment
Get-AzSubscriptionDeployment | Sort-Object Timestamp | ft DeploymentName, ProvisioningState, Timestamp
$rgName = $templateParams.resourceGroupName
Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp | ft DeploymentName,ProvisioningState,Timestamp
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $rgName -Force -AsJob
