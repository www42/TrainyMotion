# --- Scenario Hub-and-Spoke ---------------------------------------------------------
#
# This deploys
#    1. Hub virtual network (by PowerShell)
#    2. Bastion host (by ARM template)
#    3. Optional: Virtual gateway (by ARM template)
#                   with certificates
#                   with VPN client Windows
# ------------------------------------------------------------------------------------

# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription

# --- Prerequisite: Root Certificate -------------------------------------------------
Get-ChildItem -Path 'HubSpoke/RootCertificate.ps1'


# --- Parameters ---------------------------------------------------------------------
$rgName = 'rg-hub'
$location = 'westeurope'
$vnetName = 'vnet-hub'
$addressPrefix = '10.0.0.0/16'
$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0' -AddressPrefix '10.0.0.0/24'
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'AzureBastionSubnet' -AddressPrefix '10.0.255.0/26'
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallSubnet' -AddressPrefix '10.0.255.64/26'
$subnet3 = New-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix '10.0.255.128/27'
$bastionName = 'bas-hub'
$deployGateway = $false
$gatewayName = 'vgw-aztraining'
$rootCertificateName = 'AzTrainingRoot'
$rootCertificateData = 'MIIC6TCCAdGgAwIBAgIQFXhtqYOVo7RFgvpomkQhHDANBgkqhkiG9w0BAQsFADAXMRUwEwYDVQQDDAxUcmFpbnltb3Rpb24wHhcNMjMwNTEzMDc1OTI5WhcNMjQwNTEzMDgxOTI5WjAXMRUwEwYDVQQDDAxUcmFpbnltb3Rpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDMAtKL144B6DeExvQLArtHpgO0SreqSacAfeHbxIkHt1b7MWj1BlKKC8rtfDO2P2DQeebeWik9Et4NjRbvD3cGMj9z14MhZuHO7zFFKeTJtZZG9QUtKlIydHc2Vp300+LbK/zXrqQa8wFWZLMHdAPoZmjVQZs1HaIGdkkRi/ZSRITbb5S3IqsbzTOZUAXaHKI+a/w5HXXgFimWgZ4dmJJy4KJd1jNYWV0133vC2/I3/jT/1onTI/XN09EVUmPKGqJVKdOokmhhhz5cjjRprGs4HOZIfox3KvtaqWUttqjDdmF53nvynQxbj68Xse5ZTocP0/yJ7XgtFOi1rz234mxBAgMBAAGjMTAvMA4GA1UdDwEB/wQEAwICBDAdBgNVHQ4EFgQUVgyb6NZBJJ7QuIoJFOKCLBkSvCwwDQYJKoZIhvcNAQELBQADggEBAGKFpAiIrYfEVR4iF0o1ZUNVjKEgNaXtW6/jl9xfbjwCDMQPKOXWI6kk2qMyabtUyR700P9pTrNvEKV6qysgFNPxdjwyhUr6F9tqoUJAuyjl7Rk34ZdOl2RZbgEm7mKFFr5ebzTf8BLwWlHZOK3x6abCYiOBAQ4pftRtTjyS5WNDiH3WXHGeXIEsBNvBv92y0wtfpB2gu2N4FXtnPOiXL2SAWkIljrhdSZBn8rNHbP+AuEZ0ERERqgyTeW29rD3I2xrVcl9CWleeNaCPIU6A4o5zHIwLOAmdhaWtt0zucKDxbZ6iG8CcPLZgpf4tCx7xPJHkZRD8MkSCL62m1Wmj8vU='
$templateFile = 'HubSpoke/templates/main.bicep'
$templateParams = @{
    location               = $location
    bastionName            = $bastionName
    bastionSubnetId        = $bastionSubnet.Id
    deployGateway          = $deployGateway
    gatewayName            = $gatewayName
    gatewaySubnetId        = $gatewaySubnet.Id
    rootCertificateName    = $rootCertificateName
    rootCertificateData    = $rootCertificateData
}
$templateParams['deployGateway'] = $true


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Virtual network ----------------------------------------------------------------
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0,$subnet1,$subnet2,$subnet3 -Force
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$bastionSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'AzureBastionSubnet'
$gatewaySubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'GatewaySubnet'

Get-AzVirtualNetwork | ft Name,Subnets,ResourceGroupName


# --- Bastion Host, Virtual Gateway ----------------------------------------------------------------------
$templateParams['bastionSubnetId'] = $bastionSubnet.Id
$templateParams['gatewaySubnetId'] = $gatewaySubnet.Id
New-AzResourceGroupDeployment -Name 'Scenario-HubAndSpoke' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp


# --- Next steps -----------------------------------------------------------------------------------------
# 
#   --> ClientCertificate
#   --> Peering
#   --> Spoke-to-Spoke-Routing
