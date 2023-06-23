# ------------------------------------------------------------------------------------
# Scenario Hub-and-Spoke
# ------------------------------------------------------------------------------------
# This script creates root certificate 
#   * for use on an Azure Virtual Gateway (VPN)
#   * valid for 1 year
#   * root certificate's public data has to be copied into bicep template
#   * root certificate is exported as '.\RootCertificate.pfx' to sign a client vpn certificate later
# ------------------------------------------------------------------------------------
# Requires Windows PowerShell 5.1  (due to 'cert:')
# ------------------------------------------------------------------------------------

$friendlyName = 'Trainymotion Root Certificate'
$subject = 'cn=Trainymotion'
$pfxPassword = ''

$rootCertificate = New-SelfSignedCertificate `
    -FriendlyName $friendlyName `
    -Subject $subject `
    -Type Custom `
    -KeySpec Signature `
    -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 `
    -KeyLength 2048 `
    -KeyUsageProperty Sign `
    -KeyUsage CertSign `
    -CertStoreLocation 'Cert:\CurrentUser\My'

dir $rootCertificate.PSPath | Format-List FriendlyName,Subject,NotBefore,NotAfter

# Public certificate data to be copied into Bicep template (or into Azure Portal)
[System.Convert]::ToBase64String($rootCertificate.RawData) | clip 

# Export root certificate
$password = ConvertTo-SecureString -String $pfxPassword -AsPlainText -Force
$rootCertificate | Export-PfxCertificate -FilePath '.\RootCertificate.pfx' -Password $password

# Remove root certificate (We have a pfx exported) 
Remove-Item -Path $rootCertificate.PSPath
dir 'Cert:\CurrentUser\My'
