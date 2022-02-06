# GoDaddy - my account
$ApiKey    = 'dKsquMdGAehR_KRosZCvgHCRZg65QW9a5yD'
$ApiSecret = '7VWHUYpBcVbNDqqWiEe3mx'

$GoDaddy = 'https://api.godaddy.com/v1/domains'
$Headers = @{Authorization = "sso-key $($ApiKey):$($ApiSecret)"}

# GoDaddy - list all active domains
(Invoke-RestMethod -Method GET -Uri $GoDaddy -Headers $Headers) | Where-Object status -EQ 'ACTIVE' | Format-Table domain,status,expires

$Domain = 'trainymotion.com'

# Azure AD - add custom domain
New-AzureADDomain -Name $Domain
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault

# Azure AD - get DNS verification TXT record (only RecordType Txt is significant, RecordType Mx is dropped)
$VerificationDnsRecord = Get-AzureADDomainVerificationDnsRecord -Name $Domain | Where-Object RecordType -EQ 'Txt'
$VerificationDnsRecord  | Format-List Label, RecordType, Ttl, Text

# GoDaddy - custom domain - list all TXT records
Invoke-RestMethod -Method GET -Headers $Headers -Uri "$GoDaddy/$Domain/records/TXT"

# GoDaddy - custom domain - delete *all* TXT records with name `@´
Invoke-RestMethod -Method DELETE -Headers $Headers -Uri "$GoDaddy/$Domain/records/TXT/@"

# GoDaddy - custom domain - create DNS verification TXT record
$Body = @{
    name = "@"
    data = "$($VerificationDnsRecord.Text)"
    ttl  =  $($VerificationDnsRecord.Ttl)
    type = 'TXT'
} | ConvertTo-Json -AsArray

$Params = @{
    Method = "PATCH"
    Headers = $Headers
    Body = $Body
    Uri = "$GoDaddy/$Domain/records"
    ContentType = "application/json"
}
Invoke-RestMethod @Params

# Azure AD - custom domain - verify
Confirm-AzureADDomain -Name $Domain
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault

# Azure AD - custom domain - set primary
Set-AzureADDomain -Name $Domain -IsDefault $true
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault

# Azure AD - set initial domain primary (in order to delete custom domain)
Get-AzureADDomain | Where-Object IsInitial -eq $true | Set-AzureADDomain -IsDefault $true

# Azure AD - custom domain - delete
Remove-AzureADDomain -Name $Domain