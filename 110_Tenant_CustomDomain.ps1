# ----------------------------------
# Tenant
#    --> Add custom domain name
# ----------------------------------
# Requires Windows PowerShell 5.1  (due to Module 'AzureAD')
$PSVersionTable

$domainName = 'trainymotion.com'

New-AzureADDomain -Name $domainName
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault

# Get DNS verification TXT record (only RecordType Txt is significant, RecordType Mx is dropped)
$VerificationDnsRecord = Get-AzureADDomainVerificationDnsRecord -Name $domainName | Where-Object RecordType -EQ 'Txt'
$VerificationDnsRecord  | Format-List Label, RecordType, Ttl, Text


# GoDaddy - my account
$ApiKey    = 'xxx'
$ApiSecret = 'yyy'
$GoDaddy = 'https://api.godaddy.com/v1/domains'
$Headers = @{Authorization = "sso-key $($ApiKey):$($ApiSecret)"}

# GoDaddy - list all active domains
(Invoke-RestMethod -Method GET -Uri $GoDaddy -Headers $Headers) | Where-Object status -EQ 'ACTIVE' | Format-Table domain,status,expires

# GoDaddy - list all TXT records
Invoke-RestMethod -Method GET -Headers $Headers -Uri "$GoDaddy/$domainName/records/TXT"

# GoDaddy - delete *all* TXT records with name `@´
Invoke-RestMethod -Method DELETE -Headers $Headers -Uri "$GoDaddy/$domainName/records/TXT/@"

# GoDaddy - custom domain - create DNS verification TXT record
$BodyArray = @{
    name = "@"
    data = "$($VerificationDnsRecord.Text)"
    ttl  =  $($VerificationDnsRecord.Ttl)
    type = 'TXT'
}
$Body = ConvertTo-Json @( $BodyArray)

$Params = @{
    Method = "PATCH"
    Headers = $Headers
    Body = $Body
    Uri = "$GoDaddy/$domainName/records"
    ContentType = "application/json"
}

Invoke-RestMethod @Params

# Is the TXT record resolvable?
Resolve-DnsName -Name $domainName -Type TXT 

# Azure AD - custom domain - verify
Confirm-AzureADDomain -Name $domainName
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault

# Azure AD - custom domain - set primary
Set-AzureADDomain -Name $domainName -IsDefault $true
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault



# ==============================================================
#                  Remove custom domain
# ==============================================================

# Azure AD - set initial domain primary (in order to delete custom domain)
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault
$InitialDomain = (Get-AzureADDomain | Where-Object IsInitial -eq $true).Name
$InitialDomain | Set-AzureADDomain -IsDefault $true

# Get all objects referencing to custom domain
Get-AzureADDomainNameReference -Name $domainName

# List all Global Administrators
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

# Dirty: Rename user's UPN to initial domain name
Get-AzureADDomainNameReference -Name $domainName | Where-Object ObjectType -EQ 'User' | ForEach-Object {
    $Name = $_.UserPrincipalName.split('@')[0]
    Set-AzureADUser -ObjectId $_.ObjectId -UserPrincipalName "$Name@$InitialDomain"
}

# Dirty: Delete Groups
Get-AzureADDomainNameReference -Name $domainName | Where-Object ObjectType -EQ 'Group' | ForEach-Object {
    Remove-AzureADGroup -ObjectId $_.ObjectId
}


# Azure AD - custom domain - delete
Remove-AzureADDomain -Name $domainName