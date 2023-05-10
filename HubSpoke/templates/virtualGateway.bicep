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
          name: 'trainymotionRoot'
          properties: {
            publicCertData: 'MIIDBzCCAe+gAwIBAgIQVryJkzH1ZYNGKhsUHbC7CzANBgkqhkiG9w0BAQsFADAmMSQwIgYDVQQDDBt0cmFpbnltb3Rpb25Sb290Q2VydGlmaWNhdGUwHhcNMjMwMzE1MDYxMzI1WhcNMjQwMzE1MDYzMzI1WjAmMSQwIgYDVQQDDBt0cmFpbnltb3Rpb25Sb290Q2VydGlmaWNhdGUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDD6n560Sfrd4y/eN7ZYpp0e3GuT15xXs8OcdP8UVkhsDab+yQLWGk8La96g0SR4ojDpX1UqlvukPjIQ4cktiWJCxrF3vJsn72YPeit5GcGpSW+dCbTsKdkct6ZqlaI/dqwKkZAUYAlxdjxU0LCpsAgI94wkU3PQ5KQFl1McCOAQOYylzsqgjxDzIcajv+YfpdwzNuxvr90JZ5Ji7lq+W4JwctkI4phfnjVn2CprI3QcZbGc+LQOxPvzru8YSmBneUZqI/jX6dQ91kprLUUygChn1pE7oUuyCjMt8XmsP+yqk0wIa5Pg9/uf2oRfCyL/1/WYhH3GXtowC41eHoRKIYlAgMBAAGjMTAvMA4GA1UdDwEB/wQEAwICBDAdBgNVHQ4EFgQU+dgZhoTMINVxfa0xOa1PHWSvl2QwDQYJKoZIhvcNAQELBQADggEBAKAGZdokNsftBsdymk31WlTJSj7O3UO1woOJkLUfmAiFowBfgWDiAIDtExEaBxuI3Dk0MlLPcfmc5xqaaevwe//S7v0B29AeLZUF9lwyzviYHw4CeQB6ECaBo/FYYJmlEnBHUpc/nR3JfSfoOpuoyAVuW0COwtlc5WKWbIqomMFeNGOZgrM9r2PaJwfc1SDfx5HYWRnCSvZIbCEy0MGEYzcGbj0RUmCjG3Rgs5SeNUddDetl1X2VHmig0mn5etc4PMwGsizRea8NqCxGtbvJIyzcz6F+R7uHJhadwxcGDOK5uhwdRTQuh7GzqkvHJin8n5R8v+c4ad1Esxgp5VlQ2B4='
          }
        }
      ]
    }
  }
}
resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: '${gatewayName}-Pip'
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
