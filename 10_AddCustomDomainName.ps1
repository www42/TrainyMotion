# Add custom domain name
$DomainName = 'trainymotion.com'
Get-AzureADDomain
New-AzureADDomain -Name $DomainName

# Get DNS verification TXT record
$VerificationDnsRecord = Get-AzureADDomainVerificationDnsRecord -Name $DomainName | 
    Where-Object RecordType -EQ 'Txt' |
    Format-List Label, RecordType, Ttl, Text

# Create DNS verification TXT record
Add-DnsTxtGoDaddy `
    -RecordName 'trainymotion.com' `
    -TxtValue 'MS=ms21237390' `
    -GDKey '3mM44UbhLxBQK4_MVSxVE8Vy9NKBYVgfxR9gE' `
    -GDSecret 'X9v4YLEvmbaWHZVWxJN78A' `
    -GDUseOTE


$GdApiKey = '3mM44UbhLxBQK4_MVSxVE8Vy9NKBYVgfxR9gE'
$GdApiSecret = 'X9v4YLEvmbaWHZVWxJN78A'
$Uri = 'https://api.ote-godaddy.com/v1/domains'
$Headers = @{Authorization = "sso-key $($GdApiKey):$($GdApiSecret)"}

Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers -UseBasicParsing 
curl -X 'GET' \
  'https://api.ote-godaddy.com/v1/domains' \
  -H 'accept: application/json' \
  -H 'Authorization: sso-key UzQxLikm_46KxDFnbjN7cQjmw6wocia:46L26ydpkwMaKZV6uVdDWe'


# Verify custom domain name
Confirm-AzureADDomain -Name $DomainName

# Delete custom domain name
# Remove-AzureADDomain -Name $DomainName