# ------------------------------------------------------------------------------------
# Scenario Hub-and-Spoke
# ------------------------------------------------------------------------------------
# VPN Certificate (Root Certificate)
# -------------------------------------------------------------------
# Requires Windows PowerShell 5.1  (due to 'cert:')

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

# Public certificate data to be copied into Bicep template / into Azure Portal
[System.Convert]::ToBase64String($rootCertificate.RawData) | clip 

# Export Root certificate
$password = ConvertTo-SecureString -String $pfxPassword -AsPlainText -Force
$rootCertificate | Export-PfxCertificate -FilePath ./RootCertificate.pfx -Password $password

# Remove root certificate (We have a pfx exported) 
Remove-Item -Path $rootCertificate.PSPath
