# Max - Admin account for daily work
# ----------------------------------
# Max --> Global Administrator --> Tenant
# Max --> Owner                --> Subscription

# Connect to Graph
$Scopes = @(
    "User.ReadWrite.All"
    "Group.ReadWrite.All"
    "Directory.ReadWrite.All"
)
Connect-MgGraph -Scopes $Scopes
Get-MgContext | % Scopes
    
# Create user
$Domain = 'trainymotion.com'
$PasswordProfile = @{ Password = 'Pa55w.rd1234'}

$Params = @{
    GivenName = 'Max'
    Surname = 'Planck'
    DisplayName = 'Max Planck'
    UserPrincipalName = "Max@$Domain"
    MailNickname = 'Max'
    BusinessPhones = '+49 6221 837043'
    Country = 'Germany'
    City = 'Berlin'
    Department = 'Theoretical Physics'
    UsageLocation = 'DE'
    AccountEnabled = $true
    PasswordProfile = $PasswordProfile
}
$Max = New-MgUser @Params

# Assign P2 License
$P2Sku = Get-MgSubscribedSku -All | ? SkuPartNumber -EQ 'AAD_PREMIUM_P2'
Set-MgUserLicense -UserId $Max.Id -AddLicenses @{SkuId = $P2Sku.SkuId} -RemoveLicenses @()

# AzureAD roles
Get-MgDirectoryRole -All



# Cleanup
Remove-MgUser -UserId $Max.Id
