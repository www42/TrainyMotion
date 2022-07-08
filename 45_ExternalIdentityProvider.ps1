# Get Azure AD  tenant
Get-AzureADTenantDetail | Format-List DisplayName, `
                                      @{n="TenantId";e={$_.ObjectId}}, `
                                      @{n="VerifiedDomains";e={$_.VerifiedDomains.Name}}


# Google project "Azure AD B2B"
$ClientID = '1004325268767-o5klnd8p98kd6dftnbpnlu555gplap59.apps.googleusercontent.com'
$ClientSecret = 'xxx'

# Go to Google console and adjust redirect URIs
Start-Process -FilePath https://console.cloud.google.com/apis/credentials/oauthclient/1004325268767-o5klnd8p98kd6dftnbpnlu555gplap59.apps.googleusercontent.com?project=azure-ad-b2b-292013


# Register new identity provider (Create Google federation)
New-AzureADMSIdentityProvider -Type Google -Name Google -ClientId $ClientID -ClientSecret $ClientSecret
Get-AzureADMSIdentityProvider



# Test maxliebermann5@gmail.com
New-AzureADMSInvitation `
    -InvitedUserDisplayName "Max Liebermann" `
    -InvitedUserEmailAddress "maxliebermann5@gmail.com" `
    -SendInvitationMessage $true `
    -InviteRedirectUrl "http://myapps.microsoft.com"



Start-Process -FilePath https://myapps.microsoft.com/trainymotion.com