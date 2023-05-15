param gatewayName string
param location string
param subnetId string

resource gateway 'Microsoft.Network/virtualNetworkGateways@2022-09-01' = {
  name: gatewayName
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnGatewayGeneration: 'Generation1'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    activeActive: false
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '192.168.255.0/24'
        ]
      }
      vpnClientProtocols: [
        'IkeV2'
        'SSTP'
      ]
      vpnClientRootCertificates: [
        {
          name: 'TrainymotionRoot'
          properties: {
            publicCertData: 'MIIC6TCCAdGgAwIBAgIQFXhtqYOVo7RFgvpomkQhHDANBgkqhkiG9w0BAQsFADAXMRUwEwYDVQQDDAxUcmFpbnltb3Rpb24wHhcNMjMwNTEzMDc1OTI5WhcNMjQwNTEzMDgxOTI5WjAXMRUwEwYDVQQDDAxUcmFpbnltb3Rpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDMAtKL144B6DeExvQLArtHpgO0SreqSacAfeHbxIkHt1b7MWj1BlKKC8rtfDO2P2DQeebeWik9Et4NjRbvD3cGMj9z14MhZuHO7zFFKeTJtZZG9QUtKlIydHc2Vp300+LbK/zXrqQa8wFWZLMHdAPoZmjVQZs1HaIGdkkRi/ZSRITbb5S3IqsbzTOZUAXaHKI+a/w5HXXgFimWgZ4dmJJy4KJd1jNYWV0133vC2/I3/jT/1onTI/XN09EVUmPKGqJVKdOokmhhhz5cjjRprGs4HOZIfox3KvtaqWUttqjDdmF53nvynQxbj68Xse5ZTocP0/yJ7XgtFOi1rz234mxBAgMBAAGjMTAvMA4GA1UdDwEB/wQEAwICBDAdBgNVHQ4EFgQUVgyb6NZBJJ7QuIoJFOKCLBkSvCwwDQYJKoZIhvcNAQELBQADggEBAGKFpAiIrYfEVR4iF0o1ZUNVjKEgNaXtW6/jl9xfbjwCDMQPKOXWI6kk2qMyabtUyR700P9pTrNvEKV6qysgFNPxdjwyhUr6F9tqoUJAuyjl7Rk34ZdOl2RZbgEm7mKFFr5ebzTf8BLwWlHZOK3x6abCYiOBAQ4pftRtTjyS5WNDiH3WXHGeXIEsBNvBv92y0wtfpB2gu2N4FXtnPOiXL2SAWkIljrhdSZBn8rNHbP+AuEZ0ERERqgyTeW29rD3I2xrVcl9CWleeNaCPIU6A4o5zHIwLOAmdhaWtt0zucKDxbZ6iG8CcPLZgpf4tCx7xPJHkZRD8MkSCL62m1Wmj8vU='
          }
        }
      ]
    }
  }
}
resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'pip-${gatewayName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

output gatewayPip string = pip.properties.ipAddress
